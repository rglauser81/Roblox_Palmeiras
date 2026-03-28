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

    -- Aplica uniforme Palmeiras ao personagem
    local function applyPalmeirasJersey(character)
        task.wait(0.5) -- espera o character carregar
        local pal = GameConfig.PALMEIRAS
        if not pal then return end

        local bodyColors = character:FindFirstChildOfClass("BodyColors")
        if not bodyColors then
            bodyColors = Instance.new("BodyColors")
            bodyColors.Parent = character
        end

        -- Camisa verde Palmeiras (torso + bracos)
        bodyColors.TorsoColor3 = pal.GREEN_PRIMARY
        bodyColors.LeftArmColor3 = pal.GREEN_PRIMARY
        bodyColors.RightArmColor3 = pal.GREEN_PRIMARY
        -- Calção branco (pernas)
        bodyColors.LeftLegColor3 = pal.WHITE
        bodyColors.RightLegColor3 = pal.WHITE
        -- Cabeca normal
        bodyColors.HeadColor3 = Color3.fromRGB(234, 198, 158)

        -- Shirt verde com detalhes
        local shirt = character:FindFirstChildOfClass("Shirt")
        if not shirt then
            shirt = Instance.new("Shirt")
            shirt.Parent = character
        end

        -- Pants branco
        local pants = character:FindFirstChildOfClass("Pants")
        if not pants then
            pants = Instance.new("Pants")
            pants.Parent = character
        end
    end

    player.CharacterAdded:Connect(applyPalmeirasJersey)
    if player.Character then
        applyPalmeirasJersey(player.Character)
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, p in Players:GetPlayers() do onPlayerAdded(p) end

-- Inicia o loop de rodadas
RoundManager.start()
