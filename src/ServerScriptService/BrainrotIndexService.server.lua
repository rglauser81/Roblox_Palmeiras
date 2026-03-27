-- BrainrotIndexService.server.lua
-- Sistema de Indice/Colecao de Brainrots
-- Rastreia kills por tipo de mob e atribui tiers: Normal, Bronze, Prata, Ouro, Diamante, Lendario

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local MobData    = require(ReplicatedStorage.Shared.MobData)

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- ============================================================
-- Determina o tier baseado em kills
-- ============================================================
local function getTierForKills(kills)
    local bestTier = GameConfig.INDEX_TIERS[1]
    for _, tier in GameConfig.INDEX_TIERS do
        if kills >= tier.killsNeeded then
            bestTier = tier
        end
    end
    return bestTier
end

-- ============================================================
-- Registra uma kill de mob (chamado pelo FootballSystem/CombatService)
-- ============================================================
local function registerMobKill(player, mobName)
    local profile = player:FindFirstChild("PlayerProfile")
    if not profile then return end

    local indexFolder = profile:FindFirstChild("BrainrotIndex")
    if not indexFolder then return end

    local killCounter = indexFolder:FindFirstChild(mobName)
    if not killCounter then
        -- Mob nao catalogado ainda, cria contador
        killCounter = Instance.new("IntValue")
        killCounter.Name = mobName
        killCounter.Value = 0
        killCounter.Parent = indexFolder
    end

    local oldKills = killCounter.Value
    killCounter.Value = oldKills + 1
    local newKills = killCounter.Value

    -- Verifica se subiu de tier
    local oldTier = getTierForKills(oldKills)
    local newTier = getTierForKills(newKills)

    if newTier.name ~= oldTier.name then
        -- Subiu de tier! Recompensa
        local reward = GameConfig.INDEX_TIER_REWARDS[newTier.name] or 0

        -- Aplica multiplicador de rebirth
        local rebirthVal = profile:FindFirstChild("Rebirths")
        local mult = 1
        if rebirthVal then
            mult = 1 + (rebirthVal.Value * (GameConfig.REBIRTH.COIN_MULT_PER_RB or 0.5))
        end
        reward = math.floor(reward * mult)

        if reward > 0 then
            local ls = player:FindFirstChild("leaderstats")
            if ls and ls:FindFirstChild("Coins") then
                ls.Coins.Value += reward
            end
        end

        -- Notifica jogador
        Remotes.IndexTierUp:FireClient(player, mobName, newTier.name, newTier.color, reward, newKills)

        -- Anuncio global para tiers altos
        if newTier.name == "Diamante" or newTier.name == "Lendario" then
            local mobInfo = MobData.get(mobName)
            local displayName = mobInfo and mobInfo.displayName or mobName
            Remotes.GlobalAnnounce:FireAllClients(
                player.Name .. " desbloqueou " .. displayName .. " " .. newTier.name .. "!",
                newTier.color
            )
        end
    end
end

-- ============================================================
-- Retorna dados do indice para UI
-- ============================================================
local function onGetBrainrotIndex(player)
    local profile = player:FindFirstChild("PlayerProfile")
    if not profile then return {} end

    local indexFolder = profile:FindFirstChild("BrainrotIndex")
    if not indexFolder then return {} end

    local result = {}
    for mobName, mobInfo in MobData.mobs do
        local killCounter = indexFolder:FindFirstChild(mobName)
        local kills = killCounter and killCounter.Value or 0
        local tier = getTierForKills(kills)

        -- Calcula progresso para proximo tier
        local nextTier = nil
        for i, t in GameConfig.INDEX_TIERS do
            if t.killsNeeded > kills then
                nextTier = t
                break
            end
        end

        table.insert(result, {
            mobName = mobName,
            displayName = mobInfo.displayName,
            rarity = mobInfo.rarity,
            kills = kills,
            tierName = tier.name,
            tierColor = { tier.color.R * 255, tier.color.G * 255, tier.color.B * 255 },
            nextTierName = nextTier and nextTier.name or "MAX",
            nextTierKills = nextTier and nextTier.killsNeeded or kills,
        })
    end

    return result
end

-- ============================================================
-- Conecta eventos
-- ============================================================

-- Escuta kills de mobs (via MobKilled event)
Remotes:WaitForChild("MobKilled").OnServerEvent:Connect(function(_player)
    -- Ignorado: MobKilled e server->client, nao client->server
end)

-- Hook: registra kills quando o FootballSystem mata um mob
-- Usamos um BindableEvent interno para comunicacao server-server
local indexBindable = Instance.new("BindableEvent")
indexBindable.Name = "IndexMobKill"
indexBindable.Parent = ReplicatedStorage

indexBindable.Event:Connect(function(player, mobName)
    registerMobKill(player, mobName)
end)

-- Remote para UI
local indexFunc = Remotes:WaitForChild("GetBrainrotIndex", 30)
if indexFunc then
    indexFunc.OnServerInvoke = onGetBrainrotIndex
end

print("[BrainrotIndexService] Indice inicializado com", #GameConfig.INDEX_TIERS, "tiers!")
