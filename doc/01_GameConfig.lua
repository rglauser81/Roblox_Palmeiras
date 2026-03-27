-- =============================================
-- 01_GameConfig (ModuleScript)
-- LOCAL: ReplicatedStorage > Modules > GameConfig
-- =============================================
local Config = {}

-- RARIDADES E BRAINROTS
Config.Raridades = {
    {nome = "Comum",     cor = Color3.fromRGB(180,180,180), chanceBase = 50,  desbloqueio = 0},
    {nome = "Raro",      cor = Color3.fromRGB(30,144,255),  chanceBase = 25,  desbloqueio = 1},
    {nome = "Épico",     cor = Color3.fromRGB(163,53,238),  chanceBase = 12,  desbloqueio = 2},
    {nome = "Lendário",  cor = Color3.fromRGB(255,165,0),   chanceBase = 7,   desbloqueio = 3},
    {nome = "Mítico",    cor = Color3.fromRGB(255,0,80),    chanceBase = 4,   desbloqueio = 4},
    {nome = "Secreto",   cor = Color3.fromRGB(0,0,0),       chanceBase = 1.5, desbloqueio = 5},
    {nome = "Celestial",  cor = Color3.fromRGB(135,206,250), chanceBase = 0.4, desbloqueio = 6},
    {nome = "Divino",    cor = Color3.fromRGB(255,215,0),   chanceBase = 0.1, desbloqueio = 7},
}

-- Brainrots por raridade (nome, renda por segundo)
Config.Brainrots = {
    Comum = {
        {nome = "Tralalero Tralala",      renda = 10},
        {nome = "Bombardiro Crocodilo",    renda = 15},
        {nome = "Udin Din Dun",           renda = 12},
        {nome = "Ballerina Cappuccina",   renda = 8},
    },
    Raro = {
        {nome = "Tung Tung Tung Sahur",   renda = 50},
        {nome = "Brr Brr Patapim",        renda = 45},
        {nome = "Lirili Larila",          renda = 55},
    },
    ["Épico"] = {
        {nome = "Svinocolbasnik",          renda = 150},
        {nome = "Chimpanzini Bananini",    renda = 180},
        {nome = "La Vaca Saturno",         renda = 200},
    },
    ["Lendário"] = {
        {nome = "Glorbo Fruttodrillo",     renda = 500},
        {nome = "Crocobomba Palatino",     renda = 600},
    },
    ["Mítico"] = {
        {nome = "Orcalero Orcala",         renda = 2000},
        {nome = "Palazzo Giraffalino",     renda = 2500},
    },
    Secreto = {
        {nome = "Dragão Cannelloni",       renda = 8000},
        {nome = "Strawberry Elephant",     renda = 10000},
    },
    Celestial = {
        {nome = "Anjo Alviverde",          renda = 50000},
        {nome = "Serafim do Allianz",      renda = 65000},
    },
    Divino = {
        {nome = "Porco Sagrado Dourado",   renda = 500000},
    },
}

-- MUTAÇÕES
Config.Mutacoes = {
    {
        nome = "Ouro",
        cor = Color3.fromRGB(255, 215, 0),
        multiplicador = 3,
        chance = 5, -- 5% ao obter um brainrot
        efeito = "Brilho dourado"
    },
    {
        nome = "Céu Alviverde",
        cor = Color3.fromRGB(135, 235, 170),
        multiplicador = 5,
        chance = 2, -- 2% — anjinhos do Palmeiras ao lado
        efeito = "Anjinhos verdes orbitando"
    },
    {
        nome = "Diamante",
        cor = Color3.fromRGB(185, 242, 255),
        multiplicador = 10,
        chance = 0.5, -- 0.5% ultra raro
        efeito = "Cristais brilhantes"
    },
}

-- TIMERS DE SPAWN
Config.SpawnTimers = {
    Comum      = 5,     -- 5 seg
    Raro       = 15,    -- 15 seg
    ["Épico"]  = 30,    -- 30 seg
    ["Lendário"] = 60,  -- 1 min
    ["Mítico"] = 120,   -- 2 min
    Secreto    = 180,   -- 3 min
    Celestial  = 240,   -- 4 min (requisito do Nathan)
    Divino     = 3600,  -- 1 hora (requisito do Nathan)
}

-- DESAFIOS (desbloqueio de áreas)
Config.Desafios = {
    {
        nivel = 1, area = "Raro",
        tipo = "matematica",
        pergunta = "Quanto é 7 × 8?",
        resposta = "56"
    },
    {
        nivel = 2, area = "Épico",
        tipo = "logica",
        pergunta = "Sequência: 2, 6, 18, 54, ???",
        resposta = "162"
    },
    {
        nivel = 3, area = "Lendário",
        tipo = "matematica",
        pergunta = "Raiz quadrada de 144?",
        resposta = "12"
    },
    {
        nivel = 4, area = "Mítico",
        tipo = "logica",
        pergunta = "Se A=1, B=2... Quanto vale P+A+L+M+E+I+R+A+S?",
        resposta = "94" -- P=16+A=1+L=12+M=13+E=5+I=9+R=18+A=1+S=19 = 94
    },
    {
        nivel = 5, area = "Secreto",
        tipo = "matematica",
        pergunta = "2^10 = ???",
        resposta = "1024"
    },
    {
        nivel = 6, area = "Celestial",
        tipo = "logica",
        pergunta = "Fibonacci: 1,1,2,3,5,8,13,21,???",
        resposta = "34"
    },
    {
        nivel = 7, area = "Divino",
        tipo = "logica",
        pergunta = "Quantos títulos brasileiros o Palmeiras tem? (número)",
        resposta = "12"
    },
}

-- NATHAN (criador) — configurações especiais
Config.Nathan = {
    nomeDisplay = "⚡ Nathan — Criador ⚡",
    userId = 0, -- TROCAR pelo UserId real do Nathan no Roblox
    poderes = {
        "SpawnAdmin",       -- spawnar qualquer brainrot
        "MutacaoForçada",   -- forçar mutação em brainrot
        "EventoGlobal",     -- disparar chuva de brainrots
        "TeleporteLivre",   -- ir para qualquer andar
        "AuraDivina",       -- efeito visual especial
    },
    corAura = Color3.fromRGB(255, 215, 0),
    velocidadeExtra = 1.5,
}

-- ECONOMIA
Config.Economia = {
    dinheiroInicial = 100,
    custoSlotBase = 500,
    maxSlots = 20,
}

-- ANDARES DO ESTÁDIO
Config.Andares = {
    {nome = "Bilheteria",        altura = 0,   descricao = "Entrada e loja"},
    {nome = "Campo de Desafios", altura = 15,  descricao = "Resolva e desbloqueie"},
    {nome = "Arena Brainrot",    altura = 35,  descricao = "Colete e troque"},
}

return Config
