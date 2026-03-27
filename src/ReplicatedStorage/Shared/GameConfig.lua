-- GameConfig.lua
-- Configuração central do Allianz Brainrot Arena
-- ⚙️ Edite aqui para personalizar o jogo

local GameConfig = {}

-- ============================================================
-- 👑 NATHAN — CRIADOR DO JOGO
-- ============================================================
-- Coloque o UserId do Nathan aqui (número, ex: 123456789)
-- Se deixar 0, o PRIMEIRO jogador a entrar vira Nathan (modo teste)
GameConfig.NATHAN_USER_ID = 0

-- Nome exibido na tag do criador
GameConfig.NATHAN_DISPLAY_NAME = "NathanGaimer42"

-- ============================================================
-- 🏟️ ALLIANZ ARENA — ANDARES
-- ============================================================
GameConfig.FLOORS = {
    {
        id = 1,
        name = "Piso da Arquibancada",
        theme = "Stadium",
        unlockPrice = 0,       -- gratuito
        spawnHeight = 0,
        color = Color3.fromRGB(34, 139, 34),
    },
    {
        id = 2,
        name = "Corredor da Fama",
        theme = "Hallway",
        unlockPrice = 500,
        spawnHeight = 30,
        color = Color3.fromRGB(255, 165, 0),
    },
    {
        id = 3,
        name = "Camarote VIP",
        theme = "VIP",
        unlockPrice = 2000,
        spawnHeight = 60,
        color = Color3.fromRGB(148, 0, 211),
    },
    {
        id = 4,
        name = "Cobertura Lendária",
        theme = "Legendary",
        unlockPrice = 8000,
        spawnHeight = 90,
        color = Color3.fromRGB(255, 215, 0),
    },
}

-- ============================================================
-- 🌊 ONDAS
-- ============================================================
GameConfig.INTERMISSION_TIME   = 12
GameConfig.BASE_MOBS_PER_WAVE  = 5
GameConfig.MOBS_INCREMENT      = 3
GameConfig.HP_SCALE_PER_ROUND  = 0.2

-- ============================================================
-- 🛍️ LOJA
-- ============================================================
GameConfig.SHOP_ITEMS = {
    -- Armas
    { id = "sword_basic",    name = "Espada Básica",      price = 50,   category = "weapon",  damage = 25, description = "Mata o Tralalero rápido" },
    { id = "sword_fire",     name = "Espada de Fogo",     price = 300,  category = "weapon",  damage = 55, description = "AoE de fogo no inimigo" },
    { id = "sword_divine",   name = "Espada Divina",      price = 1500, category = "weapon",  damage = 120, description = "Lendária. Mata boss em 3 golpes" },

    -- Boosts
    { id = "boost_speed",    name = "Turbo Brainrot",     price = 100,  category = "boost",   duration = 30, description = "+50% velocidade por 30s" },
    { id = "boost_shield",   name = "Escudo Temporário",  price = 150,  category = "boost",   duration = 20, description = "Bloqueia próximo dano" },
    { id = "boost_magnet",   name = "Ímã de Coins",       price = 200,  category = "boost",   duration = 60, description = "+3x coins por kill por 60s" },

    -- Cosméticos
    { id = "skin_tralalero", name = "Skin Tralalero",     price = 500,  category = "cosmetic", description = "Anda igual ao Tralalero" },
    { id = "skin_bombardino",name = "Skin Bombardino",    price = 750,  category = "cosmetic", description = "Você virou o Coccodrillo" },
    { id = "aura_rainbow",   name = "Aura Arco-Íris",     price = 2000, category = "cosmetic", description = "Aura animada multicolorida" },
    { id = "aura_gold",      name = "Aura Dourada",       price = 3000, category = "cosmetic", description = "Exclusiva dos ricos" },
}

-- ============================================================
-- ⚡ PODERES ESPECIAIS DO NATHAN (comandos de chat)
-- ============================================================
GameConfig.NATHAN_COMMANDS = {
    "/chuva"   -- Chuva de coins em todos os jogadores
    ,"/divino"  -- Mata todos os mobs do mapa
    ,"/boost"   -- Dá boost de velocidade global por 60s
    ,"/evento"  -- Ativa rodada de evento especial
}

-- ============================================================
-- 🎨 VISUAIS DO NATHAN
-- ============================================================
GameConfig.NATHAN_AURA_COLOR   = Color3.fromRGB(255, 200, 0)  -- dourado
GameConfig.NATHAN_AURA_SPEED   = 2                             -- rotações/s
GameConfig.NATHAN_LIGHT_RANGE  = 20
GameConfig.NATHAN_LIGHT_BRIGHT = 1.5

-- ============================================================
-- 🏆 LEADERBOARD
-- ============================================================
GameConfig.LEADERBOARD_MAX_ENTRIES = 10
GameConfig.SAVE_INTERVAL_SECONDS   = 300  -- auto-save a cada 5 min

return GameConfig
