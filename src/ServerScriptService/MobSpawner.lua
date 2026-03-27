-- MobSpawner.lua
-- Spawna e gerencia os mobs de brainrot por onda

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local MobSpawner = {}

local activeMobs = {}
local spawnPoints = workspace:WaitForChild("SpawnPoints")

-- Tabela de mobs disponíveis no jogo (referencia nomes de modelos em ReplicatedStorage.Mobs)
local MOB_POOL = {
    { name = "Tralalero",    weight = 40, baseHp = 100, speed = 16 },
    { name = "BombardinoCoccodrillo", weight = 25, baseHp = 200, speed = 12 },
    { name = "TungTungSahur", weight = 20, baseHp = 150, speed = 18 },
    { name = "CappuccinoAssassino", weight = 10, baseHp = 400, speed = 10 },
    { name = "Lirili Larila", weight = 5, baseHp = 1000, speed = 8 },
}

local waveComplete = Instance.new("BindableEvent")

local function pickRandomMob()
    local total = 0
    for _, mob in MOB_POOL do total += mob.weight end
    local roll = math.random(1, total)
    local acc = 0
    for _, mob in MOB_POOL do
        acc += mob.weight
        if roll <= acc then return mob end
    end
end

local function scaleHp(base, round)
    return math.floor(base * (1 + (round - 1) * GameConfig.HP_SCALE_PER_ROUND))
end

function MobSpawner.spawnWave(round)
    activeMobs = {}
    local count = GameConfig.BASE_MOBS_PER_WAVE + (round - 1) * GameConfig.MOBS_INCREMENT_PER_ROUND

    local points = spawnPoints:GetChildren()

    for i = 1, count do
        local mobData = pickRandomMob()
        local point = points[math.random(1, #points)]

        local model = ReplicatedStorage.Mobs:FindFirstChild(mobData.name)
        if model then
            local clone = model:Clone()
            clone.Parent = workspace

            local humanoid = clone:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.MaxHealth = scaleHp(mobData.baseHp, round)
                humanoid.Health = humanoid.MaxHealth
                humanoid.WalkSpeed = mobData.speed
            end

            local rootPart = clone:FindFirstChild("HumanoidRootPart")
            if rootPart and point then
                rootPart.CFrame = point.CFrame
            end

            local entry = { model = clone, data = mobData }
            table.insert(activeMobs, entry)

            -- Remove da lista quando morrer
            if humanoid then
                humanoid.Died:Connect(function()
                    for i, v in activeMobs do
                        if v.model == clone then
                            table.remove(activeMobs, i)
                            break
                        end
                    end
                    task.wait(3)
                    clone:Destroy()
                    if #activeMobs == 0 then
                        waveComplete:Fire()
                    end
                end)
            end
        end

        task.wait(0.3)
    end
end

function MobSpawner.waitForWaveEnd()
    if #activeMobs == 0 then return end
    waveComplete.Event:Wait()
end

function MobSpawner.getActiveMobs()
    return activeMobs
end

return MobSpawner
