# TODO — Match Manager v1.0

> **DataReal** · Joinville, SC · Março 2026  
> **Esforço estimado:** ~40h / 2.5 semanas  
> **Migration:** `031_match_manager.sql`  
> **Pré-requisito:** Migrations 001–030 aplicadas, properties_final com 20k+ imóveis, embeddings funcional  

---

## Índice

1. [Visão Geral da Arquitetura](#1-visão-geral-da-arquitetura)
2. [SQL — Migration e Schema](#2-sql--migration-e-schema)
3. [Backend — Match Engine (Python)](#3-backend--match-engine-python)
4. [Backend — Azure Functions (API)](#4-backend--azure-functions-api)
5. [Frontend — Admin Pages (React/Next.js)](#5-frontend--admin-pages-reactnextjs)
6. [Integração Lara — UI Trivago](#6-integração-lara--ui-trivago)
7. [Plano de Implementação (4 Fases)](#7-plano-de-implementação-4-fases)
8. [Teste de Regressão](#8-teste-de-regressão)
9. [Checklist Final de Deploy](#9-checklist-final-de-deploy)

---

## 1. Visão Geral da Arquitetura

### 1.1 Fluxo Atual (antes)

```
properties_final → Azure AI Search → Lara
                                    ↘ Boardroom
Cada anúncio é tratado como imóvel individual.
dedup_hash existe mas é baseado em heurísticas simples (type+intent+bairro+quartos+area).
Não há agrupamento cross-agency.
```

### 1.2 Fluxo Novo (depois)

```
properties_final → Match Engine (batch)
                    ├→ Fingerprint Generation (embedding + features numéricas)
                    ├→ Blocking (city::neighborhood::type::intent)
                    ├→ Cosine Similarity (par-a-par dentro de blocos)
                    ├→ Classification (duplicate_high | duplicate_medium | sibling)
                    └→ Union-Find (agrupamento transitivo: A~B, B~C → {A,B,C})
                         ↓
                   property_match_candidates (pendentes)
                         ↓
                   Admin Review (manual + AI assistant)
                         ↓
                   property_match_groups (confirmados)
                         ↓
                   Azure AI Search (isCanonical, matchGroupId)
                         ↓
                   Lara UI (Trivago: 1 ficha, N anúncios)
```

### 1.3 Princípio: Camadas Separadas

| Camada | Responsabilidade | Tecnologia |
|--------|-----------------|------------|
| Match Engine | Fingerprint, blocking, cosine, union-find | **Python** (numpy, faiss-cpu, scikit-learn) |
| Persistência | Candidatos, grupos, KPIs | **PostgreSQL** (tabelas match_*) |
| Cache | Fingerprints, stats | **Redis** (TTL 7d / 1h) |
| API | CRUD matches + AI analyze | **Azure Functions** (Python) |
| UI Admin | Dashboard, review, groups | **Next.js 14 + shadcn/ui + Recharts** |
| UI Lara | Trivago view | **Next.js 14** (componente PropertyGroupCard) |

### 1.4 O que NÃO muda

- `fn_search`, `fn_agent` (Lara) — inalterados (Lara adiciona filtro `isCanonical` pós-match)
- `fn_pipeline_run` — inalterado (match roda como processo separado, não como stage)
- `properties_staging`, `scraping_raw` — inalterados
- Pipeline stages 0–5 — inalterados
- `dedup_hash` em properties_final — mantido para backward compat, match engine opera em paralelo

---

## 2. SQL — Migration e Schema

### 2.1 Migration `031_match_manager.sql`

| # | Tarefa | Detalhe | Esforço | Status |
|---|--------|---------|---------|--------|
| 2.1.1 | Criar ENUM `match_type` | `CREATE TYPE match_type AS ENUM ('duplicate_high', 'duplicate_medium', 'sibling');` | 5min | ☐ |
| 2.1.2 | Criar ENUM `match_run_status` | `CREATE TYPE match_run_status AS ENUM ('pending', 'running', 'completed', 'failed');` | 5min | ☐ |
| 2.1.3 | Criar ENUM `match_candidate_status` | `CREATE TYPE match_candidate_status AS ENUM ('pending', 'approved', 'rejected', 'merged');` | 5min | ☐ |
| 2.1.4 | Criar tabela `property_match_runs` | Rastreamento de execuções de detecção | 15min | ☐ |
| 2.1.5 | Criar tabela `property_match_candidates` | Pares propostos com cosine_score, match_type, status | 20min | ☐ |
| 2.1.6 | Criar tabela `property_match_groups` | Agrupamentos confirmados com canonical_property_id | 15min | ☐ |
| 2.1.7 | Criar tabela `property_match_group_members` | N:1 membros → grupo, PK composta (group_id, property_id) | 15min | ☐ |
| 2.1.8 | Criar índices de performance | `idx_candidates_status`, `idx_candidates_score`, `idx_group_members_property`, `idx_candidates_run` | 10min | ☐ |
| 2.1.9 | Criar view `v_match_kpis` | Agrega: total grupos, pendentes, taxa aprovação, dispersão preço | 20min | ☐ |
| 2.1.10 | Criar view `v_match_candidates_detail` | JOIN candidates + properties_final (ambos lados) + agencies | 20min | ☐ |
| 2.1.11 | Criar view `v_property_group_listings` | Membros de um grupo com agência, preço, quality_score ordenados | 15min | ☐ |
| 2.1.12 | UNIQUE constraint em candidates | `UNIQUE(property_a_id, property_b_id)` com CHECK a_id < b_id (evita pares duplicados A,B e B,A) | 10min | ☐ |

**Acceptance:** Migration aplica sem erro. Views retornam dados (podem ser 0 rows). Constraint impede pares reversos.

### 2.2 SQL Completo

```sql
-- 031_match_manager.sql

-- ── ENUMs ──
CREATE TYPE match_type AS ENUM ('duplicate_high', 'duplicate_medium', 'sibling');
CREATE TYPE match_run_status AS ENUM ('pending', 'running', 'completed', 'failed');
CREATE TYPE match_candidate_status AS ENUM ('pending', 'approved', 'rejected', 'merged');

-- ── property_match_runs ──
CREATE TABLE property_match_runs (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    scope_type      VARCHAR(20) NOT NULL,       -- all | city | neighborhood | agency
    scope_value     VARCHAR(200),
    status          match_run_status DEFAULT 'pending',
    total_properties INT DEFAULT 0,
    total_comparisons INT DEFAULT 0,
    candidates_found INT DEFAULT 0,
    duplicates_found INT DEFAULT 0,
    siblings_found  INT DEFAULT 0,
    config_json     JSONB,                      -- thresholds, blocking params
    error_message   TEXT,
    started_at      TIMESTAMPTZ,
    completed_at    TIMESTAMPTZ,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ── property_match_candidates ──
CREATE TABLE property_match_candidates (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    run_id          UUID NOT NULL REFERENCES property_match_runs(id),
    property_a_id   UUID NOT NULL REFERENCES properties_final(id),
    property_b_id   UUID NOT NULL REFERENCES properties_final(id),
    cosine_score    NUMERIC(5,4) NOT NULL,
    match_type      match_type NOT NULL,
    heuristic_flags JSONB DEFAULT '{}',          -- {"geo_close": true, "same_bedrooms": true, ...}
    ai_analysis     TEXT,
    status          match_candidate_status DEFAULT 'pending',
    reviewed_by     VARCHAR(100),
    reviewed_at     TIMESTAMPTZ,
    group_id        UUID,                        -- FK added after match_groups exists
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    
    -- Avoid duplicate pairs (A,B) and (B,A)
    CHECK (property_a_id < property_b_id),
    UNIQUE (property_a_id, property_b_id)
);

CREATE INDEX idx_candidates_status ON property_match_candidates(status);
CREATE INDEX idx_candidates_score ON property_match_candidates(cosine_score DESC);
CREATE INDEX idx_candidates_run ON property_match_candidates(run_id);
CREATE INDEX idx_candidates_type ON property_match_candidates(match_type);

-- ── property_match_groups ──
CREATE TABLE property_match_groups (
    id                      UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_type              VARCHAR(20) NOT NULL,   -- duplicate | sibling
    canonical_property_id   UUID NOT NULL REFERENCES properties_final(id),
    member_count            INT DEFAULT 2,
    avg_cosine_score        NUMERIC(5,4),
    price_spread_pct        NUMERIC(5,2),           -- max/min - 1
    is_active               BOOLEAN DEFAULT true,
    created_at              TIMESTAMPTZ DEFAULT NOW(),
    updated_at              TIMESTAMPTZ DEFAULT NOW()
);

-- Add FK now that table exists
ALTER TABLE property_match_candidates
    ADD CONSTRAINT fk_candidates_group
    FOREIGN KEY (group_id) REFERENCES property_match_groups(id);

-- ── property_match_group_members ──
CREATE TABLE property_match_group_members (
    group_id                UUID NOT NULL REFERENCES property_match_groups(id) ON DELETE CASCADE,
    property_id             UUID NOT NULL REFERENCES properties_final(id),
    agency_id               UUID REFERENCES agencies(id),
    is_canonical            BOOLEAN DEFAULT false,
    price_at_match          NUMERIC(15,2),
    quality_score_at_match  INT,
    added_at                TIMESTAMPTZ DEFAULT NOW(),
    
    PRIMARY KEY (group_id, property_id)
);

CREATE INDEX idx_group_members_property ON property_match_group_members(property_id);
CREATE INDEX idx_group_members_canonical ON property_match_group_members(is_canonical) WHERE is_canonical = true;

-- ── Views ──
CREATE OR REPLACE VIEW v_match_kpis AS
SELECT
    (SELECT COUNT(*) FROM property_match_groups WHERE is_active = true) AS total_groups,
    (SELECT COUNT(*) FROM property_match_groups WHERE is_active = true AND group_type = 'duplicate') AS duplicate_groups,
    (SELECT COUNT(*) FROM property_match_groups WHERE is_active = true AND group_type = 'sibling') AS sibling_groups,
    (SELECT COUNT(*) FROM property_match_candidates WHERE status = 'pending') AS pending_candidates,
    (SELECT COUNT(*) FROM property_match_candidates WHERE status = 'approved') AS approved_total,
    (SELECT COUNT(*) FROM property_match_candidates WHERE status = 'rejected') AS rejected_total,
    (SELECT ROUND(
        COUNT(*) FILTER (WHERE status = 'approved')::numeric /
        NULLIF(COUNT(*) FILTER (WHERE status IN ('approved', 'rejected')), 0) * 100, 1
    ) FROM property_match_candidates) AS approval_rate_pct,
    (SELECT ROUND(AVG(price_spread_pct), 1) FROM property_match_groups WHERE is_active = true) AS avg_price_spread_pct;

CREATE OR REPLACE VIEW v_match_candidates_detail AS
SELECT
    c.id, c.run_id, c.cosine_score, c.match_type, c.status,
    c.heuristic_flags, c.ai_analysis, c.reviewed_by, c.reviewed_at, c.group_id, c.created_at,
    -- Property A
    pa.id AS a_id, pa.dedup_hash AS a_hash,
    COALESCE(
        (pa.agency_listings->0->>'title'),
        pa.property_type || ' em ' || pa.neighborhood
    ) AS a_title,
    pa.property_type AS a_type, pa.listing_intent AS a_intent,
    pa.price_current AS a_price, pa.private_area_sqm AS a_area,
    pa.bedroom_count AS a_bedrooms, pa.neighborhood AS a_neighborhood,
    pa.main_image_cdn_url AS a_image,
    pa.quality_score AS a_quality,
    pa.latitude AS a_lat, pa.longitude AS a_lon,
    -- Property B
    pb.id AS b_id, pb.dedup_hash AS b_hash,
    COALESCE(
        (pb.agency_listings->0->>'title'),
        pb.property_type || ' em ' || pb.neighborhood
    ) AS b_title,
    pb.property_type AS b_type, pb.listing_intent AS b_intent,
    pb.price_current AS b_price, pb.private_area_sqm AS b_area,
    pb.bedroom_count AS b_bedrooms, pb.neighborhood AS b_neighborhood,
    pb.main_image_cdn_url AS b_image,
    pb.quality_score AS b_quality,
    pb.latitude AS b_lat, pb.longitude AS b_lon
FROM property_match_candidates c
JOIN properties_final pa ON c.property_a_id = pa.id
JOIN properties_final pb ON c.property_b_id = pb.id;

CREATE OR REPLACE VIEW v_property_group_listings AS
SELECT
    g.id AS group_id, g.group_type, g.canonical_property_id,
    g.member_count, g.price_spread_pct,
    m.property_id, m.agency_id, m.is_canonical,
    m.price_at_match, m.quality_score_at_match,
    pf.price_current, pf.private_area_sqm, pf.main_image_cdn_url,
    pf.quality_score, pf.short_description,
    a.name AS agency_name, a.slug AS agency_slug
FROM property_match_groups g
JOIN property_match_group_members m ON g.id = m.group_id
JOIN properties_final pf ON m.property_id = pf.id
LEFT JOIN agencies a ON m.agency_id = a.id
WHERE g.is_active = true
ORDER BY g.id, m.is_canonical DESC, pf.quality_score DESC;
```

### 2.3 Alterações em properties_final (para index sync)

```sql
-- Adicionar campos de match group à properties_final
ALTER TABLE properties_final
    ADD COLUMN match_group_id UUID REFERENCES property_match_groups(id),
    ADD COLUMN match_group_type VARCHAR(20),
    ADD COLUMN is_canonical BOOLEAN DEFAULT true;

CREATE INDEX idx_final_match_group ON properties_final(match_group_id) WHERE match_group_id IS NOT NULL;
CREATE INDEX idx_final_canonical ON properties_final(is_canonical) WHERE is_canonical = false;
```

---

## 3. Backend — Match Engine (Python)

### 3.1 Módulo `pipeline/matching/`

| # | Arquivo | Responsabilidade | Esforço | Status |
|---|---------|-----------------|---------|--------|
| 3.1.1 | `config.py` | Thresholds, pesos, dimensões, Redis TTLs | 30min | ☐ |
| 3.1.2 | `fingerprint.py` | Gera vetor de fingerprint para um imóvel | 2h | ☐ |
| 3.1.3 | `blocking.py` | Gera block_key, agrupa imóveis em blocos | 1h | ☐ |
| 3.1.4 | `comparator.py` | Cosine similarity + heurísticas determinísticas | 2h | ☐ |
| 3.1.5 | `classifier.py` | Classifica pares em match_type com base em score + flags | 1h | ☐ |
| 3.1.6 | `grouper.py` | Union-Find para agrupamento transitivo de pares | 1h | ☐ |
| 3.1.7 | `engine.py` | Orquestrador: escopo → fingerprint → block → compare → classify → group → persist | 3h | ☐ |
| 3.1.8 | `ai_analyzer.py` | Chama Claude Haiku para análise de par com prompt estruturado | 1h | ☐ |

**Total backend engine: ~12h**

### 3.2 Detalhamento: `fingerprint.py`

```python
"""
Gera o Match Fingerprint Vector para um imóvel.

Componentes:
  - property_type: one-hot [casa, apto, terreno, sobrado, cobertura, comercial] × peso 1.0
  - listing_intent: one-hot [venda, aluguel] × peso 1.0
  - bedroom_count: min-max [0..10] × peso 0.8
  - suite_count: min-max [0..6] × peso 0.6
  - bathroom_count: min-max [0..8] × peso 0.6
  - parking_spots: min-max [0..6] × peso 0.6
  - private_area_sqm: log-norm, bucket 5m² × peso 1.0
  - price_current: log-norm por type+intent × peso 0.8
  - geo_coords: [lat_norm, lon_norm] × peso 1.5
  - features: TF-IDF → PCA(128) × peso 0.5
  - title+desc: text-embedding-3-small(256) × peso 1.2

Vetor final: ~400 dims, L2-normalized.
"""

import numpy as np
from typing import Optional
from dataclasses import dataclass

@dataclass
class MatchFingerprint:
    property_id: str
    vector: np.ndarray          # shape: (~400,)
    block_key: str              # "Joinville::Centro::apartamento::venda"
    version: str = "v1"

async def generate_fingerprint(
    property_data: dict,
    embedding_cache: dict | None = None,
) -> MatchFingerprint:
    """
    Gera fingerprint a partir dos dados de properties_final.
    
    1. Concatena features numéricas normalizadas
    2. Gera embedding textual (ou recupera do cache/Redis)
    3. Aplica pesos por componente
    4. L2-normalize o vetor final
    """
    ...

async def batch_fingerprints(
    properties: list[dict],
    batch_size: int = 50,
) -> list[MatchFingerprint]:
    """
    Processa em batches para eficiência de embedding.
    Usa Redis cache: match:fp:{property_id}:v1
    """
    ...
```

### 3.3 Detalhamento: `comparator.py`

```python
"""
Comparação par-a-par com cosine similarity + heurísticas.

Para blocos com <= 500 imóveis: brute-force numpy.
Para blocos com > 500 imóveis: FAISS IndexFlatIP.

Heurísticas adicionais (flags):
  - geo_close: haversine < 50m
  - same_bedrooms: bedroom_count iguais
  - same_area_bucket: private_area_sqm dentro de ±10%
  - same_title_normalized: títulos normalizados (sem número) iguais
  - price_within_20pct: preço dentro de ±20%
  - same_condo: extração de nome de condomínio do título match
"""

from dataclasses import dataclass

@dataclass
class MatchPair:
    property_a_id: str
    property_b_id: str
    cosine_score: float
    heuristic_flags: dict       # {"geo_close": True, "same_bedrooms": True, ...}
    match_type: str             # classificado pelo classifier

async def compare_block(
    fingerprints: list[MatchFingerprint],
    thresholds: dict,
    use_faiss: bool = False,    # auto-detect based on block size
) -> list[MatchPair]:
    """
    Compara todos os pares dentro de um bloco.
    
    1. Se len <= 500: np.dot(matrix, matrix.T) → cosine matrix
    2. Se len > 500: FAISS IndexFlatIP com threshold
    3. Filtra pares com score >= thresholds['weak_match']
    4. Calcula heurísticas para pares acima do threshold
    """
    ...
```

### 3.4 Detalhamento: `grouper.py`

```python
"""
Union-Find para agrupamento transitivo.

Se A~B (0.96) e B~C (0.92), então {A, B, C} formam um grupo.
O canonical é o membro com maior quality_score.

Regras:
  - Apenas pares com status 'approved' são agrupados
  - Se um membro já pertence a um grupo, o par é adicionado ao grupo existente
  - O canonical é recalculado quando novos membros são adicionados
  - price_spread_pct = (max_price / min_price - 1) * 100
"""

from scipy.cluster.hierarchy import UnionFind

async def build_groups(
    approved_pairs: list[MatchPair],
    property_data: dict[str, dict],   # {property_id: {quality_score, price, ...}}
) -> list[MatchGroup]:
    """
    1. Inicializa UnionFind com todos os property_ids
    2. Union para cada par aprovado
    3. Para cada componente conectado com >= 2 membros:
       - Canonical = max(quality_score)
       - Calcula avg_cosine, price_spread_pct
       - Determina group_type (duplicate se todos são duplicate_*, sibling se algum é sibling)
    """
    ...
```

### 3.5 Detalhamento: `ai_analyzer.py`

```python
"""
Análise de match via Claude Haiku.

System prompt:
  Você é um analista de imóveis do DataReal. Analise dois anúncios e determine
  se são o MESMO imóvel (duplicata) ou unidades DIFERENTES no mesmo condomínio (siblings).
  
  Considere: endereço, metragem, quartos, fotos (descrição), preço, título.
  
  Responda APENAS em JSON:
  {
    "recommendation": "approve_duplicate" | "approve_sibling" | "reject",
    "confidence": 0.0-1.0,
    "reasoning": "...",
    "key_similarities": ["..."],
    "key_differences": ["..."],
    "risk_factors": ["..."]
  }
"""

async def analyze_match_pair(
    property_a: dict,
    property_b: dict,
    cosine_score: float,
    heuristic_flags: dict,
) -> dict:
    """
    Monta prompt com dados dos dois imóveis + contexto do score/flags.
    Chama Claude Haiku via Anthropic API.
    Parseia resposta JSON.
    Retorna análise estruturada.
    """
    ...
```

---

## 4. Backend — Azure Functions (API)

| # | Function | Route | Method | Esforço | Status |
|---|----------|-------|--------|---------|--------|
| 4.1 | `fn_match_detect` | `/api/admin/match/detect` | POST | 2h | ☐ |
| 4.2 | `fn_match_candidates` | `/api/admin/match/candidates` | GET | 1.5h | ☐ |
| 4.3 | `fn_match_review` | `/api/admin/match/review` | POST | 2h | ☐ |
| 4.4 | `fn_match_ai_analyze` | `/api/admin/match/ai-analyze` | POST | 1.5h | ☐ |
| 4.5 | `fn_match_groups` | `/api/admin/match/groups` | GET | 1h | ☐ |
| 4.6 | `fn_match_stats` | `/api/admin/match/stats` | GET | 1h | ☐ |
| 4.7 | `fn_match_group_detail` | `/api/admin/match/groups/{id}` | GET | 1h | ☐ |

**Total API: ~10h**

### 4.1 fn_match_detect

```
POST /api/admin/match/detect
Auth: admin function key

Request:
{
  "scope_type": "neighborhood",       // all | city | neighborhood | agency
  "scope_value": "Centro",
  "thresholds": {                     // opcional, defaults abaixo
    "duplicate_high": 0.95,
    "duplicate_medium": 0.88,
    "sibling": 0.75,
    "weak_match": 0.65
  },
  "max_properties": 5000,             // safety limit
  "dry_run": false                    // se true, retorna resultado sem persistir
}

Response (200):
{
  "run_id": "uuid",
  "status": "completed",
  "total_properties": 347,
  "blocks_processed": 12,
  "total_comparisons": 12480,
  "candidates_found": 23,
  "duplicates_found": 15,
  "siblings_found": 8,
  "duration_ms": 4200
}

Error (400): scope_type inválido, max_properties excedido
Error (409): outra run já em execução para o mesmo escopo
```

### 4.2 fn_match_candidates

```
GET /api/admin/match/candidates?status=pending&match_type=duplicate_high&neighborhood=Centro&min_score=0.90&page=1&page_size=20

Response (200):
{
  "candidates": [
    {
      "id": "uuid",
      "cosine_score": 0.96,
      "match_type": "duplicate_high",
      "status": "pending",
      "heuristic_flags": {"geo_close": true, "same_bedrooms": true},
      "property_a": {
        "id": "uuid", "title": "Apto 3 quartos Centro",
        "price": 450000, "area": 85, "bedrooms": 3,
        "neighborhood": "Centro", "agency": "Anagê",
        "image": "https://...", "quality_score": 78
      },
      "property_b": { ... }
    }
  ],
  "total": 23,
  "page": 1,
  "page_size": 20
}
```

### 4.3 fn_match_review

```
POST /api/admin/match/review

Request:
{
  "candidate_id": "uuid",
  "action": "approve",               // approve | reject
  "match_type_override": null,        // permite mudar de duplicate para sibling
  "notes": "Mesmo apto, fotos idênticas"
}

— OU batch:
{
  "candidate_ids": ["uuid1", "uuid2"],
  "action": "approve"
}

Lógica de approve:
  1. Marca candidate como 'approved'
  2. Busca se property_a ou property_b já pertencem a algum grupo
     - Se sim: adiciona o outro imóvel ao grupo existente
     - Se não: cria novo grupo
  3. Atualiza canonical_property_id (max quality_score)
  4. Recalcula member_count, avg_cosine_score, price_spread_pct
  5. Atualiza properties_final.match_group_id, .is_canonical para membros

Response (200): { "group_id": "uuid", "action": "approved", "members": 3 }
```

### 4.4 fn_match_ai_analyze

```
POST /api/admin/match/ai-analyze
Request: { "candidate_id": "uuid" }

1. Busca candidate + dados completos de ambos imóveis
2. Chama ai_analyzer.analyze_match_pair()
3. Salva ai_analysis no candidate
4. Retorna análise

Response (200):
{
  "recommendation": "approve_duplicate",
  "confidence": 0.92,
  "reasoning": "Mesmo endereço (Rua XV de Novembro, 1234), metragem idêntica (85m²)...",
  "key_similarities": ["endereço", "metragem", "quartos", "andar"],
  "key_differences": ["preço (5% diferença)", "fotos diferentes"],
  "risk_factors": []
}
```

---

## 5. Frontend — Admin Pages (React/Next.js)

### 5.1 Componentes compartilhados

| # | Componente | Descrição | Esforço | Status |
|---|-----------|-----------|---------|--------|
| 5.1.1 | `PropertyCompareCard` | Side-by-side de 2 imóveis com foto, preço, features | 1.5h | ☐ |
| 5.1.2 | `MatchScoreBadge` | Badge colorido com score e match_type | 20min | ☐ |
| 5.1.3 | `HeuristicFlags` | Badges dos flags ativos (geo_close, same_bedrooms, etc.) | 20min | ☐ |
| 5.1.4 | `AIAnalysisPanel` | Painel que mostra resultado da análise IA com recomendação | 30min | ☐ |
| 5.1.5 | `MatchGroupCard` | Card Trivago: canônico em destaque + membros abaixo | 1h | ☐ |
| 5.1.6 | `DetectModal` | Modal para iniciar detecção com escopo e thresholds | 30min | ☐ |

### 5.2 Página: `/admin/matches` — Dashboard

| # | Tarefa | Detalhe | Esforço | Status |
|---|--------|---------|---------|--------|
| 5.2.1 | KPI cards | 4 cards: Grupos Ativos, Pendentes, Taxa Aprovação, Dispersão Preço | 1h | ☐ |
| 5.2.2 | Chart: Top bairros | Recharts BarChart com top 10 bairros por duplicatas | 30min | ☐ |
| 5.2.3 | Chart: Distribuição tipos | Recharts PieChart split duplicate vs sibling | 30min | ☐ |
| 5.2.4 | Chart: Evolução temporal | Recharts LineChart de candidatos/aprovações por semana | 30min | ☐ |
| 5.2.5 | Botão Detectar Matches | Abre `DetectModal`, chama fn_match_detect | 30min | ☐ |
| 5.2.6 | Tabela runs recentes | Lista últimas 10 runs com status, escopo, resultado | 30min | ☐ |
| 5.2.7 | Sidebar + routing | Adicionar "Matches" na sidebar do admin com badge de pendentes | 20min | ☐ |

### 5.3 Página: `/admin/matches/review` — Fila de Revisão

| # | Tarefa | Detalhe | Esforço | Status |
|---|--------|---------|---------|--------|
| 5.3.1 | Filtros no topo | Select: bairro, match_type, score mínimo | 30min | ☐ |
| 5.3.2 | Tabela de candidatos | Colunas: score, tipo, bairro, preço A vs B, ações | 1h | ☐ |
| 5.3.3 | Expand row | Ao clicar: abre `PropertyCompareCard` com dados completos | 1h | ☐ |
| 5.3.4 | Botão AI Analyze | Chama fn_match_ai_analyze, mostra `AIAnalysisPanel` | 30min | ☐ |
| 5.3.5 | Ações approve/reject | Botões individuais + checkbox para batch action | 30min | ☐ |
| 5.3.6 | React Query hooks | `useMatchCandidates`, `useMatchReview`, `useMatchAIAnalyze` | 30min | ☐ |

### 5.4 Página: `/admin/matches/groups` — Grupos

| # | Tarefa | Detalhe | Esforço | Status |
|---|--------|---------|---------|--------|
| 5.4.1 | Lista de grupos | Cards com canônico, badge membros, dispersão preço | 1h | ☐ |
| 5.4.2 | Drill-down membros | Expandir grupo para ver todos os anúncios (UI Trivago) | 1h | ☐ |
| 5.4.3 | Ações de grupo | Remover membro, alterar canônico, desativar grupo | 30min | ☐ |
| 5.4.4 | Filtros | Por bairro, tipo (duplicate/sibling), agência | 20min | ☐ |

### 5.5 AI Assistant Sidebar

| # | Tarefa | Detalhe | Esforço | Status |
|---|--------|---------|---------|--------|
| 5.5.1 | Chat sidebar component | Reutilizar padrão do inspector chat | 1h | ☐ |
| 5.5.2 | Tools definition | search_matches, analyze_pair, get_stats, approve_match | 30min | ☐ |
| 5.5.3 | System prompt | Contexto de match analysis + tools disponíveis | 30min | ☐ |

**Total frontend: ~12h**

---

## 6. Integração Lara — UI Trivago

| # | Tarefa | Detalhe | Esforço | Status |
|---|--------|---------|---------|--------|
| 6.1 | Atualizar AI Search index | Adicionar campos: matchGroupId, matchGroupType, isCanonical, groupMemberCount, groupPriceMin, groupPriceMax | 1h | ☐ |
| 6.2 | Atualizar indexer stage | Incluir novos campos ao indexar properties_final | 30min | ☐ |
| 6.3 | Filtro de busca Lara | Adicionar `isCanonical eq true OR matchGroupId eq null` nos search results | 30min | ☐ |
| 6.4 | `PropertyGroupCard` componente | Card da Lara que mostra "Anunciado por N agências" com expand | 2h | ☐ |
| 6.5 | Ficha expandida com Compare Preços | Seção dentro da ficha: anúncios de todas agências ordenados por preço | 1h | ☐ |
| 6.6 | Seção "No mesmo condomínio" | Cards de siblings quando existem | 30min | ☐ |
| 6.7 | Hook `usePropertyGroup` | React Query: fetch grupo + membros dado um matchGroupId | 30min | ☐ |

**Total Lara integration: ~6h**

---

## 7. Plano de Implementação (4 Fases)

### Fase 1: Schema + Core Algorithm (12h, ~4 dias)

| # | Tarefa | Esforço | Status |
|---|--------|---------|--------|
| 1.1 | Aplicar migration `031_match_manager.sql` | 30min | ☐ |
| 1.2 | `requirements.txt`: + numpy, faiss-cpu, scikit-learn, scipy | 10min | ☐ |
| 1.3 | `pipeline/matching/config.py` | 30min | ☐ |
| 1.4 | `pipeline/matching/fingerprint.py` + testes | 2h | ☐ |
| 1.5 | `pipeline/matching/blocking.py` + testes | 1h | ☐ |
| 1.6 | `pipeline/matching/comparator.py` + testes | 2h | ☐ |
| 1.7 | `pipeline/matching/classifier.py` + testes | 1h | ☐ |
| 1.8 | `pipeline/matching/grouper.py` + testes | 1h | ☐ |
| 1.9 | `pipeline/matching/engine.py` (orquestrador) | 3h | ☐ |
| 1.10 | Teste E2E: rodar engine para bairro Centro com dry_run | 1h | ☐ |

**Acceptance:** Engine roda para um bairro, gera fingerprints, compara blocos, classifica pares e produz candidatos. dry_run retorna resultados sem persistir.

### Fase 2: API Layer (10h, ~3 dias)

| # | Tarefa | Esforço | Status |
|---|--------|---------|--------|
| 2.1 | `fn_match_detect/__init__.py` | 2h | ☐ |
| 2.2 | `fn_match_candidates/__init__.py` | 1.5h | ☐ |
| 2.3 | `fn_match_review/__init__.py` (com lógica de grupo) | 2h | ☐ |
| 2.4 | `fn_match_ai_analyze/__init__.py` + `ai_analyzer.py` | 1.5h | ☐ |
| 2.5 | `fn_match_groups/__init__.py` | 1h | ☐ |
| 2.6 | `fn_match_stats/__init__.py` | 1h | ☐ |
| 2.7 | `fn_match_group_detail/__init__.py` | 1h | ☐ |
| 2.8 | Registrar functions no `host.json` / `function.json` | 15min | ☐ |
| 2.9 | Testar APIs via curl/httpie | 30min | ☐ |

**Acceptance:** Todas as 7 Azure Functions deployam sem erro. Detect → Candidates → Review → Groups fluxo completo funciona via curl.

### Fase 3: Admin UI (12h, ~4 dias)

| # | Tarefa | Esforço | Status |
|---|--------|---------|--------|
| 3.1 | Componentes compartilhados (5.1.1–5.1.6) | 4h | ☐ |
| 3.2 | Dashboard `/admin/matches` (5.2.1–5.2.7) | 3.5h | ☐ |
| 3.3 | Review `/admin/matches/review` (5.3.1–5.3.6) | 3.5h | ☐ |
| 3.4 | Groups `/admin/matches/groups` (5.4.1–5.4.4) | 2.5h | ☐ |
| 3.5 | AI sidebar (5.5.1–5.5.3) | 2h | ☐ |
| 3.6 | Sidebar routing + badge pendentes | 20min | ☐ |

**Acceptance:** Admin navega entre Dashboard → Review → Groups. Detectar matches, revisar candidatos (com AI), e visualizar grupos funciona E2E.

### Fase 4: Lara Integration + Polish (6h, ~2 dias)

| # | Tarefa | Esforço | Status |
|---|--------|---------|--------|
| 4.1 | Atualizar AI Search index schema (6.1–6.2) | 1.5h | ☐ |
| 4.2 | Filtro de busca isCanonical (6.3) | 30min | ☐ |
| 4.3 | `PropertyGroupCard` + ficha expandida (6.4–6.6) | 3h | ☐ |
| 4.4 | Hook `usePropertyGroup` (6.7) | 30min | ☐ |
| 4.5 | Regression test suite | 30min | ☐ |

**Acceptance:** Lara mostra resultados sem duplicatas. Imóveis agrupados exibem "Anunciado por N agências" com compare de preços.

---

## 8. Teste de Regressão

### 8.1 Escopo: O que DEVE continuar funcionando

Todo teste deve ser executado **antes** e **depois** do deploy.

### 8.2 Checklist de Regressão

#### A. Match Engine

| # | Teste | Comando/Ação | Resultado Esperado | ☐ |
|---|-------|-------------|-------------------|---|
| A.1 | Detect dry_run | `POST /api/admin/match/detect {"scope_type":"neighborhood","scope_value":"Centro","dry_run":true}` | Status 200, candidates_found >= 0, nada persistido | ☐ |
| A.2 | Detect persiste | Mesma chamada com `dry_run: false` | Registros em property_match_runs e property_match_candidates | ☐ |
| A.3 | Candidates list | `GET /api/admin/match/candidates?status=pending` | Lista paginada com dados de ambos imóveis | ☐ |
| A.4 | AI Analyze | `POST /api/admin/match/ai-analyze {"candidate_id":"<id>"}` | JSON com recommendation, confidence, reasoning | ☐ |
| A.5 | Approve candidate | `POST /api/admin/match/review {"candidate_id":"<id>","action":"approve"}` | Grupo criado, properties_final.match_group_id atualizado | ☐ |
| A.6 | Group listing | `GET /api/admin/match/groups` | Grupos com membros, canonical correto | ☐ |
| A.7 | Stats | `GET /api/admin/match/stats` | KPIs não-nulos | ☐ |

#### B. Pipeline Existente (Não Regressão)

| # | Teste | Query SQL | Resultado Esperado | ☐ |
|---|-------|----------|-------------------|---|
| B.1 | properties_final intacta | `SELECT COUNT(*) FROM properties_final WHERE status='active'` | >= valor pré-deploy | ☐ |
| B.2 | Pipeline health | `SELECT * FROM v_pipeline_health` | error_rate_pct < 5% | ☐ |
| B.3 | Lara search | `POST /api/search {"query":"apartamentos centro"}` | Retorna resultados | ☐ |
| B.4 | Agent Lara | `POST /api/agent {"message":"casas até 500 mil"}` | Streaming SSE funciona | ☐ |

#### C. Match Data Integrity

```sql
-- Verificar consistência dos grupos
SELECT
    g.id, g.member_count,
    COUNT(m.property_id) AS actual_members,
    g.canonical_property_id,
    EXISTS(
        SELECT 1 FROM property_match_group_members m2
        WHERE m2.group_id = g.id AND m2.is_canonical = true
    ) AS has_canonical
FROM property_match_groups g
LEFT JOIN property_match_group_members m ON g.id = m.group_id
WHERE g.is_active = true
GROUP BY g.id
HAVING g.member_count != COUNT(m.property_id)
    OR NOT EXISTS(
        SELECT 1 FROM property_match_group_members m2
        WHERE m2.group_id = g.id AND m2.is_canonical = true
    );
-- Deve retornar 0 rows
```

### 8.3 Script de Regressão

```bash
#!/bin/bash
# scripts/regression_match.sh

set -e
echo "🔍 Match Manager Regression Test"
echo "================================="

API_BASE="${API_BASE:-https://dr-prod-func.azurewebsites.net/api}"
ADMIN_KEY="${ADMIN_FUNCTION_KEY}"

# A. Detect (dry run)
echo "\n🔎 A.1 Detect dry_run..."
DETECT=$(curl -sf -X POST "$API_BASE/admin/match/detect" \
  -H "x-functions-key: $ADMIN_KEY" -H "Content-Type: application/json" \
  -d '{"scope_type":"neighborhood","scope_value":"Centro","dry_run":true,"max_properties":100}')
FOUND=$(echo $DETECT | jq '.candidates_found')
echo "✅ Dry run: $FOUND candidates found"

# B. Existing pipeline
echo "\n📊 B. Pipeline health..."
curl -sf "$API_BASE/admin/health" -H "x-functions-key: $ADMIN_KEY" | \
  jq '.stages[] | select(.error_rate_pct > 5)'
echo "✅ Pipeline health OK"

# C. Lara search
echo "\n🔍 C. Lara search..."
SEARCH=$(curl -sf "$API_BASE/search" -H "Content-Type: application/json" \
  -d '{"query":"apartamentos centro","top":3}')
COUNT=$(echo $SEARCH | jq '.count')
[ "$COUNT" -gt 0 ] && echo "✅ Search: $COUNT results" || echo "❌ Search failed"

# D. DB integrity
echo "\n💾 D. Database..."
psql $DATABASE_URL -c "SELECT * FROM v_match_kpis;"

echo "\n✅ Regression complete"
```

---

## 9. Checklist Final de Deploy

| # | Ação | Responsável | ☐ |
|---|------|------------|---|
| 1 | Executar regression ANTES do deploy (baseline) | Dev | ☐ |
| 2 | Aplicar migration 031 no PostgreSQL de produção | Dev | ☐ |
| 3 | Aplicar ALTER TABLE em properties_final (match_group_id, etc.) | Dev | ☐ |
| 4 | `pip install numpy faiss-cpu scikit-learn scipy` no requirements.txt | Dev | ☐ |
| 5 | Deploy Azure Functions (7 novas functions) | CI/CD | ☐ |
| 6 | Deploy frontend Next.js com páginas /admin/matches/* | CI/CD | ☐ |
| 7 | Rodar primeira detecção: scope_type=neighborhood, scope_value=Centro | Dev | ☐ |
| 8 | Revisar primeiros 10 candidatos manualmente | Dev | ☐ |
| 9 | Verificar grupos criados com v_property_group_listings | Dev | ☐ |
| 10 | Atualizar AI Search index com novos campos | Dev | ☐ |
| 11 | Re-indexar properties_final para popular matchGroupId | Dev | ☐ |
| 12 | Testar Lara: busca NÃO mostra duplicatas | Dev | ☐ |
| 13 | Executar regression DEPOIS do deploy | Dev | ☐ |
| 14 | Monitorar Application Insights por 24h | Dev | ☐ |

---

## Resumo dos Arquivos

| Arquivo | Ação | Fase |
|---------|------|------|
| `infra/sql/031_match_manager.sql` | Criar | 1 |
| `requirements.txt` | + numpy, faiss-cpu, scikit-learn, scipy | 1 |
| `pipeline/matching/__init__.py` | Criar | 1 |
| `pipeline/matching/config.py` | Criar | 1 |
| `pipeline/matching/fingerprint.py` | Criar | 1 |
| `pipeline/matching/blocking.py` | Criar | 1 |
| `pipeline/matching/comparator.py` | Criar | 1 |
| `pipeline/matching/classifier.py` | Criar | 1 |
| `pipeline/matching/grouper.py` | Criar | 1 |
| `pipeline/matching/engine.py` | Criar | 1 |
| `pipeline/matching/ai_analyzer.py` | Criar | 2 |
| `fn_match_detect/__init__.py` | Criar | 2 |
| `fn_match_candidates/__init__.py` | Criar | 2 |
| `fn_match_review/__init__.py` | Criar | 2 |
| `fn_match_ai_analyze/__init__.py` | Criar | 2 |
| `fn_match_groups/__init__.py` | Criar | 2 |
| `fn_match_stats/__init__.py` | Criar | 2 |
| `fn_match_group_detail/__init__.py` | Criar | 2 |
| `frontend/app/admin/matches/page.tsx` | Criar | 3 |
| `frontend/app/admin/matches/review/page.tsx` | Criar | 3 |
| `frontend/app/admin/matches/groups/page.tsx` | Criar | 3 |
| `frontend/components/match/*` | Criar (6 componentes) | 3 |
| `frontend/hooks/useMatch*.ts` | Criar (hooks React Query) | 3 |
| `frontend/components/lara/PropertyGroupCard.tsx` | Criar | 4 |
| `infra/search/index_definition.json` | Editar (+6 campos) | 4 |
| `pipeline/stages/indexer.py` | Editar (incluir match fields) | 4 |
| `backend/search/search_handler.py` | Editar (filtro isCanonical) | 4 |

**Estimativa total: ~40h / 2.5 semanas**  
**Ordem: Fase 1 → 2 → 3 → 4**

---

*DataReal — TODO Match Manager v1.0 — Março 2026*
