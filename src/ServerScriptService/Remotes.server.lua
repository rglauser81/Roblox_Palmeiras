-- Remotes.server.lua
-- Cria TODOS os RemoteEvents e RemoteFunctions do jogo
-- ⚠️ Este script DEVE ser o primeiro a rodar (coloque acima dos outros no Explorer)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Evita duplicação se o servidor reiniciar
local existing = ReplicatedStorage:FindFirstChild("Remotes")
if existing then existing:Destroy() end

local remotesFolder = Instance.new("Folder")
remotesFolder.Name = "Remotes"
remotesFolder.Parent = ReplicatedStorage

local function makeEvent(name)
    local e = Instance.new("RemoteEvent")
    e.Name = name
    e.Parent = remotesFolder
    return e
end

local function makeFunction(name)
    local f = Instance.new("RemoteFunction")
    f.Name = name
    f.Parent = remotesFolder
    return f
end

-- ── RODADAS ────────────────────────────────────────────────
makeEvent("RoundStarted")       -- server -> client : (roundNumber)
makeEvent("RoundEnded")         -- server -> client : (roundNumber)

-- ── COMBAT ─────────────────────────────────────────────────
makeEvent("MobKilled")          -- server -> client : (mobName, coinsRewarded)
makeEvent("PlayerDied")         -- server -> client : ()
makeEvent("DealDamage")         -- client -> server : (targetModel, damage)
makeEvent("PlayerHit")          -- server -> client : (damage)

-- ── LOJA ───────────────────────────────────────────────────
makeFunction("BuyItem")         -- client -> server : (itemId) -> (ok, msg)
makeFunction("UnlockFloor")     -- client -> server : (floorId) -> (ok, msg)
makeEvent("OpenShop")           -- server -> client : ()
makeEvent("ShopResult")         -- server -> client : (ok, msg)
makeEvent("ApplyCosmetic")      -- server -> client : (cosmeticId)
makeEvent("FloorUnlocked")      -- server -> client : (floorId)

-- ── UI / NOTIFICAÇÕES ──────────────────────────────────────
makeEvent("GlobalAnnounce")     -- server -> client : (text, color)
makeEvent("UpdateStats")        -- server -> client : (statsTable)

-- ── FUTEBOL ────────────────────────────────────────────────
makeEvent("KickBall")           -- client -> server : (direction, charge)
makeEvent("GoalScored")         -- server -> client : (coins, combo)
makeEvent("GoalChallengeStart") -- server -> client : (duration)
makeEvent("GoalChallengeEnd")   -- server -> client : (totalGoals, totalCoins)
makeEvent("BallHitMob")         -- server -> client : (mobName, damage)

print("[Remotes] Todas as remotas criadas:", #remotesFolder:GetChildren())
