-- GameConfig.lua
-- Configuracao central do Brainrot Football Stadium
-- Estrutura: 1 campo grande + arquibancadas + mini-games espalhados

local GameConfig = {}

-- ============================================================
-- NATHAN — CRIADOR DO JOGO
-- ============================================================
GameConfig.NATHAN_USER_ID = 1774574751189
GameConfig.NATHAN_DISPLAY_NAME = "NathanGaimer42"

-- ============================================================
-- ESTADIO — Layout unico (sem andares multiplos)
-- ============================================================
GameConfig.STADIUM = {
    FIELD_LENGTH   = 240,   -- comprimento do campo (X) +50%
    FIELD_WIDTH    = 150,   -- largura do campo (Z) +50%
    FIELD_Y        = 0,     -- altura do gramado
    STAND_HEIGHT   = 20,    -- altura das arquibancadas
    STAND_ROWS     = 5,     -- fileiras de assentos
}

-- Mantém FLOORS para compatibilidade (1 andar só)
GameConfig.FLOORS = {
    {
        id = 1,
        name = "Estadio Brainrot",
        theme = "Stadium",
        unlockPrice = 0,
        spawnHeight = 0,
        color = Color3.fromRGB(34, 139, 34),
    },
}

-- ============================================================
-- ONDAS — mobs invadem o campo 
-- ============================================================
GameConfig.INTERMISSION_TIME       = 25
GameConfig.BASE_MOBS_PER_WAVE      = 5
GameConfig.MOBS_INCREMENT          = 3
GameConfig.MOBS_INCREMENT_PER_ROUND = GameConfig.MOBS_INCREMENT
GameConfig.HP_SCALE_PER_ROUND      = 0.2
GameConfig.MAX_DIFFICULTY_ROUND    = 50

-- ============================================================
-- ECONOMIA
-- ============================================================
GameConfig.COINS_PER_KILL           = 10
GameConfig.RARE_MOB_COIN_MULTIPLIER = 5

-- ============================================================
-- REBIRTH — Reseta coins/kills em troca de multiplicador permanente
-- ============================================================
GameConfig.REBIRTH = {
    BASE_COST        = 1000,    -- custo do primeiro rebirth
    COST_MULTIPLIER  = 2.2,     -- custo escala por rebirth (custo = BASE * MULT^rebirth)
    COIN_MULT_PER_RB = 0.5,     -- +0.5x coins por rebirth (rebirth 1 = 1.5x, 2 = 2x)
    DMG_MULT_PER_RB  = 0.1,     -- +10% dano por rebirth
    MAX_REBIRTHS     = 50,
    RESET_KILLS      = true,    -- reseta kills no rebirth
    RESET_COINS      = true,    -- reseta coins no rebirth
}

-- ============================================================
-- INDICE BRAINROT — Colecao de todos os brainrots com tiers
-- ============================================================
GameConfig.INDEX_TIERS = {
    { name = "Normal",    color = Color3.fromRGB(180, 180, 180), killsNeeded = 0,    icon = "" },
    { name = "Bronze",    color = Color3.fromRGB(205, 127, 50),  killsNeeded = 10,   icon = "" },
    { name = "Prata",     color = Color3.fromRGB(192, 192, 192), killsNeeded = 50,   icon = "" },
    { name = "Ouro",      color = Color3.fromRGB(255, 215, 0),   killsNeeded = 200,  icon = "" },
    { name = "Diamante",  color = Color3.fromRGB(0, 200, 255),   killsNeeded = 1000, icon = "" },
    { name = "Lendario",  color = Color3.fromRGB(255, 50, 255),  killsNeeded = 5000, icon = "" },
}

-- Recompensas por completar tier de um mob
GameConfig.INDEX_TIER_REWARDS = {
    Normal   = 0,
    Bronze   = 50,
    Prata    = 200,
    Ouro     = 1000,
    Diamante = 5000,
    Lendario = 25000,
}

-- ============================================================
-- LOJA
-- ============================================================
GameConfig.SHOP_ITEMS = {
    -- Bolas
    { id = "ball_basic",     name = "Bola Classica",       price = 0,    category = "weapon",  damage = 20, description = "Chute basico. Ja vem com voce!" },
    { id = "ball_fire",      name = "Bola de Fogo",        price = 400,  category = "weapon",  damage = 60, description = "Explode no impacto! AoE de 12 studs" },
    { id = "ball_golden",    name = "Bola Dourada",        price = 1200, category = "weapon",  damage = 45, description = "+3x coins por kill com esta bola" },
    { id = "ball_ice",       name = "Bola de Gelo",        price = 600,  category = "weapon",  damage = 35, description = "Congela mobs por 3s no impacto" },
    { id = "ball_thunder",   name = "Bola Trovao",         price = 2000, category = "weapon",  damage = 100, description = "Raio em cadeia! Atinge ate 4 mobs" },

    -- Boosts
    { id = "boost_speed",    name = "Turbo Brainrot",      price = 100,  category = "boost",   duration = 30, description = "+50% velocidade por 30s" },
    { id = "boost_shield",   name = "Escudo Temporario",   price = 150,  category = "boost",   duration = 20, description = "Bloqueia proximo dano" },
    { id = "boost_magnet",   name = "Ima de Coins",        price = 200,  category = "boost",   duration = 60, description = "+3x coins por kill por 60s" },
    { id = "boot_turbo",     name = "Chuteira Turbo",      price = 250,  category = "boost",   duration = 60, description = "Chuta 2x mais rapido por 60s" },
    { id = "boot_curve",     name = "Chuteira Curva",      price = 500,  category = "boost",   duration = 45, description = "Bolas rastreiam o mob mais proximo" },

    -- Cosmeticos
    { id = "skin_tralalero", name = "Skin Tralalero",      price = 500,  category = "cosmetic", description = "Anda igual ao Tralalero" },
    { id = "skin_bombardino",name = "Skin Bombardino",     price = 750,  category = "cosmetic", description = "Voce virou o Coccodrillo" },
    { id = "trail_soccer",   name = "Rastro de Gramado",   price = 400,  category = "cosmetic", description = "Deixa rastro verde por onde anda" },
    { id = "aura_rainbow",   name = "Aura Arco-Iris",      price = 2000, category = "cosmetic", description = "Aura animada multicolorida" },
    { id = "aura_gold",      name = "Aura Dourada",         price = 3000, category = "cosmetic", description = "Exclusiva dos ricos" },
}

-- ============================================================
-- PODERES DO NATHAN
-- ============================================================
GameConfig.NATHAN_COMMANDS = {
    "/chuva", "/divino", "/boost", "/evento",
}
GameConfig.NATHAN_AURA_COLOR   = Color3.fromRGB(255, 200, 0)
GameConfig.NATHAN_AURA_SPEED   = 2
GameConfig.NATHAN_LIGHT_RANGE  = 20
GameConfig.NATHAN_LIGHT_BRIGHT = 1.5

-- ============================================================
-- FUTEBOL — Sistema de Chute + Desafio de Gol
-- ============================================================
GameConfig.FOOTBALL = {
    BALL_SPEED          = 130,
    BALL_MAX_SPEED      = 240,
    BALL_BASE_DAMAGE    = 20,
    BALL_MAX_DAMAGE     = 80,
    BALL_LIFETIME       = 4,
    BALL_SIZE           = 2.4,
    BALL_BOUNCE_COUNT   = 3,

    KICK_COOLDOWN       = 0.7,
    CHARGE_TIME         = 1.2,

    GOAL_CHALLENGE_DURATION = 18,
    GOAL_COINS_BASE     = 50,
    GOAL_COMBO_MULT     = 1.5,
    KEEPER_BASE_SPEED   = 14,
    KEEPER_SPEED_SCALE  = 1.5,

    FIRE_BALL_AOE       = 12,
    FIRE_BALL_DAMAGE    = 60,
    GOLDEN_COIN_MULT    = 3,
}

-- ============================================================
-- MINI-GAMES INTERATIVOS (espalhados pelo estadio)
-- ============================================================
GameConfig.MINIGAMES = {
    {
        id = "dribble_course",
        name = "Pista de Dribles",
        description = "Desvie dos cones brainrot!",
        duration = 15,
        reward = 80,
        position = Vector3.new(-82, 0, 52),
    },
    {
        id = "penalty_shootout",
        name = "Cobranca de Penalti",
        description = "Marque gols contra o goleiro!",
        duration = 20,
        reward = 100,
        position = Vector3.new(82, 0, -52),
    },
    {
        id = "keepy_uppy",
        name = "Embaixadinhas",
        description = "Mantenha a bola no ar!",
        duration = 12,
        reward = 60,
        position = Vector3.new(0, 0, -60),
    },
    {
        id = "tackle_dodge",
        name = "Fuja do Carrinho",
        description = "Desvie dos brainrots que dao carrinho!",
        duration = 15,
        reward = 90,
        position = Vector3.new(0, 0, 60),
    },
    {
        id = "target_kick",
        name = "Tiro ao Alvo",
        description = "Acerte os alvos com a bola!",
        duration = 18,
        reward = 120,
        position = Vector3.new(-82, 0, -52),
    },
    {
        id = "speed_dribble",
        name = "Corrida com Bola",
        description = "Corra com a bola ate o outro lado!",
        duration = 10,
        reward = 70,
        position = Vector3.new(82, 0, 52),
    },
}

-- ============================================================
-- BRAINROT NPCs (decorativos + interativos pelo estadio)
-- ============================================================
GameConfig.STADIUM_NPCS = {
    { name = "Tralalero Torcedor",   color = "Bright red",    pos = Vector3.new(-45, 0, 72),  action = "cheer" },
    { name = "Bombardino Goleiro",   color = "Bright green",  pos = Vector3.new(-105, 0, 0),  action = "guard" },
    { name = "Tung Tung Arbitro",    color = "Really black",  pos = Vector3.new(0, 0, 0),     action = "whistle" },
    { name = "Cappuccino Vendedor",  color = "Brown",         pos = Vector3.new(45, 0, 72),   action = "sell" },
    { name = "Lirili Comentarista",  color = "Bright purple", pos = Vector3.new(-105, 20, 60), action = "commentate" },
    { name = "Brio Boss Final",      color = "Gold",          pos = Vector3.new(0, 0, -72),   action = "boss" },
}

-- ============================================================
-- LEADERBOARD
-- ============================================================
GameConfig.LEADERBOARD_MAX_ENTRIES = 10
GameConfig.SAVE_INTERVAL_SECONDS   = 300

return GameConfig
