-- CombatService.server.lua
-- ⚔️ Gerencia dano, kills, recompensas e interação com mobs

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local MobData    = require(ReplicatedStorage.Shared.MobData)

local Remotes

local function getRemotes()
    if not Remotes then
        Remotes = ReplicatedStorage:WaitForChild("Remotes")
    end
    return Remotes
end

-- ============================================================
-- Utilitários
-- ============================================================

local function addCoins(player, amount)
    local ls = player:FindFirstChild("leaderstats")
    if not ls then return end
    if ls:FindFirstChild("Coins") then
        ls.Coins.Value += amount
    end
end

local function addKill(player)
    local ls = player:FindFirstChild("leaderstats")
    if not ls then return end
    if ls:FindFirstChild("Kills") then
        ls.Kills.Value += 1
    end
end

local function getCoinMultiplier(player)
    local profile = player:FindFirstChild("PlayerProfile")
    if profile and profile:FindFirstChild("CoinMultiplier") then
        return profile.CoinMultiplier.Value
    end
    return 1
end

local function hasShield(player)
    local profile = player:FindFirstChild("PlayerProfile")
    return profile and profile:FindFirstChild("Shield") ~= nil
end

local function consumeShield(player)
    local profile = player:FindFirstChild("PlayerProfile")
    if profile then
        local shield = profile:FindFirstChild("Shield")
        if shield then shield:Destroy(); return true end
    end
    return false
end

-- ============================================================
-- Arma: script de dano quando ferramenta atinge mob
-- O servidor recebe o evento do cliente com o dano
-- ============================================================

local function onDealDamage(player, targetModel, damage)
    if not player or not targetModel then return end

    -- Valida que o target não é outro player
    if Players:GetPlayerFromCharacter(targetModel) then return end

    local humanoid = targetModel:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    -- Limita damage entre 1 e 9999 para evitar exploits
    damage = math.clamp(damage, 1, 9999)

    humanoid:TakeDamage(damage)

    if humanoid.Health <= 0 then
        -- Identifica o mob
        local mobName = targetModel.Name
        local mobInfo = MobData.get(mobName)
        local baseReward = mobInfo and mobInfo.coinReward or GameConfig.COINS_PER_KILL or 10

        local multiplier = getCoinMultiplier(player)
        local reward = math.floor(baseReward * multiplier)

        addCoins(player, reward)
        addKill(player)

        -- Notifica o cliente
        getRemotes().MobKilled:FireClient(player, mobName, reward)

        -- Verifica se andar subiu de kills (leaderboard atualizado via DataService)
        local ls = player:FindFirstChild("leaderstats")
        if ls and ls:FindFirstChild("Kills") then
            local highRound = player:FindFirstChild("PlayerProfile")
            -- atualiza highestRound se aplicável (tratado no DataService)
        end
    end
end

-- ============================================================
-- Dano recebido pelo player vindo de mob
-- ============================================================

local function onPlayerHit(player, damage)
    if not player then return end
    local char = player.Character
    if not char then return end

    -- Verifica escudo
    if hasShield(player) then
        consumeShield(player)
        getRemotes().GlobalAnnounce:FireClient(player,
            "🛡️ Escudo absorveu o golpe!", Color3.fromRGB(100, 200, 255))
        return
    end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:TakeDamage(math.clamp(damage, 1, 999))
    end
end

-- ============================================================
-- Listeners de Remotes
-- ============================================================

task.spawn(function()
    local remotes = getRemotes()

    -- Cliente envia: qual mob atacou, quanto de dano
    local dealDamageEvt = remotes:WaitForChild("DealDamage", 10)
    if dealDamageEvt then
        dealDamageEvt.OnServerEvent:Connect(function(player, targetModel, damage)
            onDealDamage(player, targetModel, damage)
        end)
    end

    -- Mob server-side que machuca player (chamado pelo MobAI)
    local playerHitEvt = remotes:WaitForChild("PlayerHit", 10)
    if playerHitEvt then
        playerHitEvt.OnServerEvent:Connect(function(player, damage)
            onPlayerHit(player, damage)
        end)
    end
end)

print("[CombatService] Inicializado.")
