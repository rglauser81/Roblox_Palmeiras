-- RebirthService.server.lua
-- Sistema de Rebirth: reseta coins/kills em troca de multiplicador permanente
-- Cada rebirth aumenta o multiplicador de coins e dano

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local RB = GameConfig.REBIRTH

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- ============================================================
-- Calcula custo do proximo rebirth
-- ============================================================
local function getRebirthCost(currentRebirths)
    return math.floor(RB.BASE_COST * (RB.COST_MULTIPLIER ^ currentRebirths))
end

-- ============================================================
-- Calcula multiplicador total
-- ============================================================
local function getCoinMultiplier(rebirths)
    return 1 + (rebirths * RB.COIN_MULT_PER_RB)
end

local function getDamageMultiplier(rebirths)
    return 1 + (rebirths * RB.DMG_MULT_PER_RB)
end

-- ============================================================
-- Handler de Rebirth
-- ============================================================
local function onRebirth(player)
    local ls = player:FindFirstChild("leaderstats")
    local profile = player:FindFirstChild("PlayerProfile")
    if not ls or not profile then return false, "Dados nao carregados." end

    local rebirthVal = profile:FindFirstChild("Rebirths")
    if not rebirthVal then return false, "Dados nao carregados." end

    local currentRebirths = rebirthVal.Value
    if currentRebirths >= RB.MAX_REBIRTHS then
        return false, "Rebirth maximo atingido!"
    end

    local cost = getRebirthCost(currentRebirths)
    local coins = ls:FindFirstChild("Coins")
    if not coins or coins.Value < cost then
        return false, "Coins insuficientes! Precisa de " .. cost .. " coins."
    end

    -- Executa rebirth
    rebirthVal.Value = currentRebirths + 1

    -- Reseta coins e kills
    if RB.RESET_COINS and coins then
        coins.Value = 0
    end
    if RB.RESET_KILLS then
        local kills = ls:FindFirstChild("Kills")
        if kills then kills.Value = 0 end
    end

    -- Atualiza multiplicadores no perfil
    local coinMult = profile:FindFirstChild("CoinMultiplier")
    if coinMult then
        coinMult.Value = getCoinMultiplier(rebirthVal.Value)
    end

    local dmgMult = profile:FindFirstChild("DamageMultiplier")
    if dmgMult then
        dmgMult.Value = getDamageMultiplier(rebirthVal.Value)
    end

    -- Atualiza leaderboard
    local rbLeader = ls:FindFirstChild("Rebirths")
    if rbLeader then
        rbLeader.Value = rebirthVal.Value
    end

    -- Notifica
    local newCost = getRebirthCost(rebirthVal.Value)
    local newMult = getCoinMultiplier(rebirthVal.Value)

    Remotes.RebirthDone:FireClient(player, rebirthVal.Value, newMult, newCost)
    Remotes.GlobalAnnounce:FireAllClients(
        player.Name .. " fez REBIRTH " .. rebirthVal.Value .. "! (" .. string.format("%.1f", newMult) .. "x coins)",
        Color3.fromRGB(255, 100, 255)
    )

    print("[RebirthService]", player.Name, "rebirth", rebirthVal.Value)
    return true, "Rebirth " .. rebirthVal.Value .. " concluido! Multiplicador: " .. string.format("%.1f", newMult) .. "x"
end

-- ============================================================
-- Info do rebirth (para UI)
-- ============================================================
local function onGetRebirthInfo(player)
    local profile = player:FindFirstChild("PlayerProfile")
    if not profile then return nil end

    local rebirthVal = profile:FindFirstChild("Rebirths")
    local currentRebirths = rebirthVal and rebirthVal.Value or 0

    return {
        rebirths = currentRebirths,
        cost = getRebirthCost(currentRebirths),
        coinMult = getCoinMultiplier(currentRebirths),
        dmgMult = getDamageMultiplier(currentRebirths),
        nextCoinMult = getCoinMultiplier(currentRebirths + 1),
        nextDmgMult = getDamageMultiplier(currentRebirths + 1),
        maxRebirths = RB.MAX_REBIRTHS,
    }
end

-- ============================================================
-- Conecta
-- ============================================================
local rebirthFunc = Remotes:WaitForChild("DoRebirth", 30)
if rebirthFunc then
    rebirthFunc.OnServerInvoke = onRebirth
end

local infoFunc = Remotes:WaitForChild("GetRebirthInfo", 30)
if infoFunc then
    infoFunc.OnServerInvoke = onGetRebirthInfo
end

print("[RebirthService] Inicializado! Max rebirths:", RB.MAX_REBIRTHS)
