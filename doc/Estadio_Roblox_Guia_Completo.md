# Estádio de Futebol — Roblox Studio em 30 min

## Pré-requisitos
- Roblox Studio aberto e logado
- Novo projeto com template **Baseplate**

---

## ETAPA 1 — Campo de futebol (5 min)

### 1.1 Criar o gramado
No Explorer, clique em **Workspace** > Insert Object > **Part**

No painel **Properties**, configure:
- **Name**: `Campo`
- **Size**: `200, 1, 120`
- **Position**: `0, 0.5, 0`
- **Color**: `0, 128, 0` (verde escuro)
- **Material**: `Grass`
- **Anchored**: ✅

### 1.2 Linha central
Insert > Part:
- **Name**: `LinhaCentral`
- **Size**: `1, 0.1, 120`
- **Position**: `0, 1.1, 0`
- **Color**: `255, 255, 255`
- **Material**: `SmoothPlastic`
- **Anchored**: ✅

### 1.3 Círculo central (simplificado com cilindro)
Insert > Part > mude **Shape** para `Cylinder`:
- **Name**: `CirculoCentral`
- **Size**: `0.2, 40, 40`
- **Rotation**: `0, 0, 90`
- **Position**: `0, 1.1, 0`
- **Color**: `255, 255, 255`
- **Material**: `SmoothPlastic`
- **Transparency**: `0.7`
- **Anchored**: ✅

### 1.4 Áreas (grandes)
Crie 2 Parts para as áreas:

**Área esquerda:**
- **Size**: `40, 0.1, 50`
- **Position**: `-80, 1.1, 0`
- **Color**: branco, **Transparency**: `0.7`

**Área direita:**
- **Size**: `40, 0.1, 50`
- **Position**: `80, 1.1, 0`
- **Color**: branco, **Transparency**: `0.7`

---

## ETAPA 2 — Gols (5 min)

Cada gol é feito de 3 Parts (2 postes + 1 travessão) + 1 Part detector invisível.

### Gol A (esquerdo — vermelho)

**Poste esquerdo:**
- **Name**: `PosteA1`
- **Size**: `2, 12, 2`
- **Position**: `-101, 7, -10`
- **Color**: `255, 255, 255`, **Anchored**: ✅

**Poste direito:**
- **Name**: `PosteA2`
- **Size**: `2, 12, 2`
- **Position**: `-101, 7, 10`
- **Color**: `255, 255, 255`, **Anchored**: ✅

**Travessão:**
- **Name**: `TravessaoA`
- **Size**: `2, 2, 22`
- **Position**: `-101, 13, 0`
- **Color**: `255, 255, 255`, **Anchored**: ✅

**Detector de gol (invisível):**
- **Name**: `GolA`
- **Size**: `4, 12, 20`
- **Position**: `-103, 7, 0`
- **Transparency**: `1`
- **CanCollide**: ❌
- **Anchored**: ✅

### Gol B (direito — azul)
Repita o mesmo com posição espelhada (X = `101` e `103` positivo):

**Poste esquerdo:** Position `101, 7, -10`
**Poste direito:** Position `101, 7, 10`
**Travessão:** Position `101, 13, 0`
**Detector:** Name `GolB`, Position `103, 7, 0`, Transparency 1, CanCollide off

---

## ETAPA 3 — Bola chutável (8 min)

### 3.1 Criar a bola
Insert > Part > Shape: **Ball**
- **Name**: `Bola`
- **Size**: `4, 4, 4`
- **Position**: `0, 3, 0`
- **Color**: `255, 255, 255`
- **Material**: `SmoothPlastic`
- **Anchored**: ❌
- **CustomPhysicalProperties**: ativar e setar **Density** = `0.5`, **Friction** = `0.3`, **Elasticity** = `0.6`

### 3.2 Script de chute
Clique direito na **Bola** > Insert Object > **Script**

Cole este código:

```lua
local bola = script.Parent
local FORCA_CHUTE = 80
local COOLDOWN = 0.5
local ultimoChute = {}

bola.Touched:Connect(function(hit)
    local humanoid = hit.Parent:FindFirstChild("Humanoid")
    if not humanoid then return end

    local player = game.Players:GetPlayerFromCharacter(hit.Parent)
    if not player then return end

    -- Cooldown por jogador
    local agora = tick()
    if ultimoChute[player.UserId] and (agora - ultimoChute[player.UserId]) < COOLDOWN then
        return
    end
    ultimoChute[player.UserId] = agora

    -- Direção do chute = da posição do jogador para a bola
    local direcao = (bola.Position - hit.Parent.HumanoidRootPart.Position).Unit
    direcao = Vector3.new(direcao.X, 0.3, direcao.Z) -- leve elevação

    bola.AssemblyLinearVelocity = direcao * FORCA_CHUTE
end)
```

---

## ETAPA 4 — Placar e detecção de gol (8 min)

### 4.1 Criar o placar (BillboardGui)
1. Em **Workspace**, Insert > **Part**
   - **Name**: `PainelPlacar`
   - **Size**: `20, 10, 1`
   - **Position**: `0, 25, -65` (atrás do campo, visível)
   - **Color**: `30, 30, 30`
   - **Anchored**: ✅
   - **Material**: `Neon`

2. Dentro de `PainelPlacar`, Insert > **SurfaceGui**
   - **Face**: `Front`

3. Dentro do **SurfaceGui**, Insert > **TextLabel**
   - **Name**: `PlacarTexto`
   - **Size**: `{1, 0}, {1, 0}` (preenche tudo)
   - **BackgroundTransparency**: `1`
   - **Text**: `0 x 0`
   - **TextColor3**: `255, 255, 255`
   - **TextScaled**: ✅
   - **Font**: `GothamBold`

### 4.2 Script de gol e placar
Em **ServerScriptService**, Insert > **Script**

```lua
local bola = workspace:WaitForChild("Bola")
local golA = workspace:WaitForChild("GolA")
local golB = workspace:WaitForChild("GolB")
local placarTexto = workspace.PainelPlacar.SurfaceGui.PlacarTexto

local pontosA = 0  -- Time A marca no gol B
local pontosB = 0  -- Time B marca no gol A

local posicaoInicial = Vector3.new(0, 3, 0)
local golAtivo = true

local function resetarBola()
    bola.Anchored = true
    bola.Position = posicaoInicial
    bola.AssemblyLinearVelocity = Vector3.zero
    bola.AssemblyAngularVelocity = Vector3.zero
    task.wait(2)
    bola.Anchored = false
    golAtivo = true
end

local function atualizarPlacar()
    placarTexto.Text = pontosA .. " x " .. pontosB
end

-- Gol no lado B = ponto para Time A
golB.Touched:Connect(function(hit)
    if hit == bola and golAtivo then
        golAtivo = false
        pontosA = pontosA + 1
        atualizarPlacar()
        resetarBola()
    end
end)

-- Gol no lado A = ponto para Time B
golA.Touched:Connect(function(hit)
    if hit == bola and golAtivo then
        golAtivo = false
        pontosB = pontosB + 1
        atualizarPlacar()
        resetarBola()
    end
end)

-- Reset se a bola cair do mapa
game:GetService("RunService").Heartbeat:Connect(function()
    if bola.Position.Y < -20 then
        golAtivo = false
        resetarBola()
    end
end)
```

---

## ETAPA 5 — Arquibancada e acabamento (4 min)

### 5.1 Arquibancada simples
Crie 4 Parts (uma para cada lado) como degraus:

**Arquibancada lateral 1:**
- **Size**: `200, 8, 15`
- **Position**: `0, 4, -75`
- **Color**: `100, 100, 100`
- **Material**: `Concrete`
- **Anchored**: ✅

**Arquibancada lateral 2:**
- **Size**: `200, 8, 15`
- **Position**: `0, 4, 75`
- **Color**: `100, 100, 100`

**Arquibancada fundo A:**
- **Size**: `15, 8, 150`
- **Position**: `-115, 4, 0`
- **Color**: `100, 100, 100`

**Arquibancada fundo B:**
- **Size**: `15, 8, 150`
- **Position**: `115, 4, 0`
- **Color**: `100, 100, 100`

### 5.2 Spawn Points
Em Workspace, Insert > **SpawnLocation** (2x):

**Spawn Time A:**
- **Position**: `-50, 1, 0`
- **Color**: `255, 80, 80` (vermelho)
- **Anchored**: ✅

**Spawn Time B:**
- **Position**: `50, 1, 0`
- **Color**: `80, 80, 255` (azul)
- **Anchored**: ✅

### 5.3 Iluminação
Em **Lighting** no Explorer:
- **Ambient**: `150, 150, 150`
- **Brightness**: `2`
- **ClockTime**: `14` (tarde ensolarada)
- **OutdoorAmbient**: `150, 150, 150`

---

## PUBLICAR

1. **File** > **Publish to Roblox As...**
2. Dê o nome: `Estádio Brainrot Arena` (ou o que preferir)
3. Descrição: `Mini futebol multiplayer — chute, roube e faça gols!`
4. **Create** e pronto!

---

## Melhorias futuras (pós-30min)

- **Times**: usar TeamService para dividir jogadores
- **Tempo de partida**: contagem regressiva de 5 minutos
- **Power-ups**: velocidade extra, chute mais forte
- **Brainrot twist**: brainrot characters como skins
- **Efeitos de gol**: partículas, som, câmera shake
- **Torcida**: NPCs animados na arquibancada
- **Câmera de replay**: gravar o gol e mostrar replay
