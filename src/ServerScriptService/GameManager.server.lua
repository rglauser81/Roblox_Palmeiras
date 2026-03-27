-- GameManager.server.lua
-- Gerencia o loop principal do jogo: rodadas, spawns e estado global

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameConfig   = require(ReplicatedStorage.Shared.GameConfig)
local RoundManager = require(script.Parent.RoundManager)

local function onPlayerAdded(player)
    print("[GameManager] Jogador entrou:", player.Name)

    -- Leaderstats visíveis no leaderboard
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local kills = Instance.new("IntValue")
    kills.Name = "Kills"
    kills.Value = 0
    kills.Parent = leaderstats

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Value = 0
    coins.Parent = leaderstats

    local highRound = Instance.new("IntValue")
    highRound.Name = "M. Rodada"
    highRound.Value = 0
    highRound.Parent = leaderstats

    local rebirthLeader = Instance.new("IntValue")
    rebirthLeader.Name = "Rebirths"
    rebirthLeader.Value = 0
    rebirthLeader.Parent = leaderstats

    -- Perfil interno (não visível no leaderboard — usado pelos serviços)
    local profile = Instance.new("Folder")
    profile.Name   = "PlayerProfile"
    profile.Parent = player

    -- Rebirth data
    local rebirths = Instance.new("IntValue")
    rebirths.Name = "Rebirths"
    rebirths.Value = 0
    rebirths.Parent = profile

    local coinMult = Instance.new("NumberValue")
    coinMult.Name = "CoinMultiplier"
    coinMult.Value = 1
    coinMult.Parent = profile

    local dmgMult = Instance.new("NumberValue")
    dmgMult.Name = "DamageMultiplier"
    dmgMult.Value = 1
    dmgMult.Parent = profile

    -- Brainrot Index (kills por tipo de mob)
    local brainrotIndex = Instance.new("Folder")
    brainrotIndex.Name = "BrainrotIndex"
    brainrotIndex.Parent = profile
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, p in Players:GetPlayers() do onPlayerAdded(p) end

-- Inicia o loop de rodadas
RoundManager.start()
