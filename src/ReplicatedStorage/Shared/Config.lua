-- Config.lua
-- Configurações centrais do jogo — edite aqui para balancear

local Config = {}

-- Tempo de intervalo entre rodadas (segundos)
Config.INTERMISSION_TIME = 10

-- Quantidade base de mobs por onda
Config.BASE_MOBS_PER_WAVE = 5

-- Quantos mobs a mais por rodada
Config.MOBS_INCREMENT_PER_ROUND = 3

-- Multiplicador de HP por rodada (ex: 0.2 = +20% por rodada)
Config.HP_SCALE_PER_ROUND = 0.2

-- Dificuldade máxima de rodada (depois disso mantém o mesmo scaling)
Config.MAX_DIFFICULTY_ROUND = 50

-- Coins base por kill
Config.COINS_PER_KILL = 10

-- Bonus de coins para mobs raros
Config.RARE_MOB_COIN_MULTIPLIER = 5

return Config
