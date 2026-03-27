-- GameConfig.lua
-- Configuração central do Allianz Brainrot Arena
-- ⚙️ Edite aqui para personalizar o jogo

local GameConfig = {}

-- ============================================================
-- 👑 NATHAN — CRIADOR DO JOGO
-- ============================================================
-- Coloque o UserId do Nathan aqui (número, ex: 123456789)
-- Se deixar 0, o PRIMEIRO jogador a entrar vira Nathan (modo teste)
GameConfig.NATHAN_USER_ID = 1774574751189

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
GameConfig.INTERMISSION_TIME       = 22  -- inclui o desafio de gol (18s) + pausa
GameConfig.BASE_MOBS_PER_WAVE      = 5
GameConfig.MOBS_INCREMENT          = 3
GameConfig.MOBS_INCREMENT_PER_ROUND = GameConfig.MOBS_INCREMENT  -- alias
GameConfig.HP_SCALE_PER_ROUND      = 0.2
GameConfig.MAX_DIFFICULTY_ROUND    = 50

-- ============================================================
-- 💰 ECONOMIA
-- ============================================================
GameConfig.COINS_PER_KILL           = 10
GameConfig.RARE_MOB_COIN_MULTIPLIER = 5

-- ============================================================
-- 🛍️ LOJA
-- ============================================================
GameConfig.SHOP_ITEMS = {
    -- Armas (Bolas)
    { id = "ball_basic",     name = "Bola Clássica ⚽",    price = 0,    category = "weapon",  damage = 20, description = "Chute básico. Já vem com você!" },
    { id = "ball_fire",      name = "Bola de Fogo 🔥",     price = 400,  category = "weapon",  damage = 60, description = "Explode no impacto! AoE de 12 studs" },
    { id = "ball_golden",    name = "Bola Dourada ⭐",      price = 1200, category = "weapon",  damage = 45, description = "+3x coins por kill com esta bola" },
    { id = "ball_ice",       name = "Bola de Gelo ❄️",     price = 600,  category = "weapon",  damage = 35, description = "Congela mobs por 3s no impacto" },
    { id = "ball_thunder",   name = "Bola Trovão ⚡",      price = 2000, category = "weapon",  damage = 100, description = "Raio em cadeia! Atinge até 4 mobs" },

    -- Boosts
    { id = "boost_speed",    name = "Turbo Brainrot",      price = 100,  category = "boost",   duration = 30, description = "+50% velocidade por 30s" },
    { id = "boost_shield",   name = "Escudo Temporário",   price = 150,  category = "boost",   duration = 20, description = "Bloqueia próximo dano" },
    { id = "boost_magnet",   name = "Ímã de Coins",        price = 200,  category = "boost",   duration = 60, description = "+3x coins por kill por 60s" },
    { id = "boot_turbo",     name = "Chuteira Turbo ⚡",   price = 250,  category = "boost",   duration = 60, description = "Chuta 2x mais rápido por 60s" },
    { id = "boot_curve",     name = "Chuteira Curva 🌀",   price = 500,  category = "boost",   duration = 45, description = "Bolas rastreiam o mob mais próximo" },

    -- Cosméticos
    { id = "skin_tralalero", name = "Skin Tralalero",      price = 500,  category = "cosmetic", description = "Anda igual ao Tralalero" },
    { id = "skin_bombardino",name = "Skin Bombardino",     price = 750,  category = "cosmetic", description = "Você virou o Coccodrillo" },
    { id = "trail_soccer",   name = "Rastro de Gramado 🌿",price = 400,  category = "cosmetic", description = "Deixa rastro verde por onde anda" },
    { id = "aura_rainbow",   name = "Aura Arco-Íris",      price = 2000, category = "cosmetic", description = "Aura animada multicolorida" },
    { id = "aura_gold",      name = "Aura Dourada",         price = 3000, category = "cosmetic", description = "Exclusiva dos ricos" },
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
-- ⚽ FUTEBOL — Sistema de Chute + Desafio de Gol
-- ============================================================
GameConfig.FOOTBALL = {
    -- Bola
    BALL_SPEED          = 130,     -- velocidade base da bola (studs/s)
    BALL_MAX_SPEED      = 240,     -- velocidade com carga máxima
    BALL_BASE_DAMAGE    = 20,      -- dano do chute rápido
    BALL_MAX_DAMAGE     = 80,      -- dano do chute carregado
    BALL_LIFETIME       = 4,       -- segundos antes de sumir
    BALL_SIZE           = 2.4,     -- tamanho da bola (diâmetro)
    BALL_BOUNCE_COUNT   = 3,       -- quicar até N vezes nas paredes

    -- Chute
    KICK_COOLDOWN       = 0.7,     -- cooldown entre chutes (s)
    CHARGE_TIME         = 1.2,     -- tempo para carga máxima (s)

    -- Desafio de Gol (intermission)
    GOAL_CHALLENGE_DURATION = 18,  -- duração do desafio (s)
    GOAL_COINS_BASE     = 50,      -- coins por gol
    GOAL_COMBO_MULT     = 1.5,     -- multiplicador por gol consecutivo
    KEEPER_BASE_SPEED   = 14,      -- velocidade do goleiro
    KEEPER_SPEED_SCALE  = 1.5,     -- aumento por rodada

    -- Bola especial: Fogo
    FIRE_BALL_AOE       = 12,      -- raio da explosão
    FIRE_BALL_DAMAGE    = 60,      -- dano da explosão

    -- Bola especial: Dourada
    GOLDEN_COIN_MULT    = 3,       -- multiplicador de coins
}

-- ============================================================
-- 🏆 LEADERBOARD
-- ============================================================
GameConfig.LEADERBOARD_MAX_ENTRIES = 10
GameConfig.SAVE_INTERVAL_SECONDS   = 300  -- auto-save a cada 5 min

return GameConfig
