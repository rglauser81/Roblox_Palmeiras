-- MobSpawner.lua
-- Spawna e gerencia os mobs de brainrot por onda

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local MobSpawner = {}

local activeMobs = {}

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

-- Coleta todos os SpawnPoints de qualquer andar (SpawnPoints_Floor1, SpawnPoints_Floor2, etc.)
local function getAllSpawnPoints()
    local points = {}
    for _, folder in workspace:GetChildren() do
        if folder:IsA("Folder") and folder.Name:match("^SpawnPoints") then
            for _, pt in folder:GetChildren() do
                table.insert(points, pt)
            end
        end
    end
    return points
end

-- Cria um mob placeholder quando o modelo não existe em ReplicatedStorage.Mobs
local function createPlaceholderMob(mobData)
    local model = Instance.new("Model")
    model.Name = mobData.name

    local rootPart = Instance.new("Part")
    rootPart.Name = "HumanoidRootPart"
    rootPart.Size = Vector3.new(2, 4, 2)
    rootPart.Anchored = false
    rootPart.CanCollide = true
    rootPart.BrickColor = BrickColor.new("Bright red")
    rootPart.Parent = model

    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(2, 1, 1)
    head.Position = rootPart.Position + Vector3.new(0, 2.5, 0)
    head.Anchored = false
    head.CanCollide = true
    head.BrickColor = BrickColor.new("Bright yellow")
    head.Parent = model

    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = model

    -- Nametag
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Nametag"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Adornee = head
    billboard.Parent = head

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = mobData.name
    nameLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 18
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Parent = billboard

    model.PrimaryPart = rootPart

    return model
end

function MobSpawner.spawnWave(round)
    activeMobs = {}
    local count = GameConfig.BASE_MOBS_PER_WAVE + (round - 1) * GameConfig.MOBS_INCREMENT

    local points = getAllSpawnPoints()
    if #points == 0 then
        warn("[MobSpawner] Nenhum SpawnPoint encontrado! Aguardando ArenaBuilder...")
        -- Espera até que pelo menos um SpawnPoints_Floor* exista
        while #points == 0 do
            task.wait(1)
            points = getAllSpawnPoints()
        end
    end

    local mobsFolder = ReplicatedStorage:FindFirstChild("Mobs")

    for i = 1, count do
        local mobData = pickRandomMob()
        local point = points[math.random(1, #points)]

        local template = mobsFolder and mobsFolder:FindFirstChild(mobData.name)
        local clone
        if template then
            clone = template:Clone()
        else
            clone = createPlaceholderMob(mobData)
        end

        clone.Parent = workspace

        local humanoid = clone:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.MaxHealth = scaleHp(mobData.baseHp, round)
            humanoid.Health = humanoid.MaxHealth
            humanoid.WalkSpeed = mobData.speed
        end

        local rootPart = clone:FindFirstChild("HumanoidRootPart")
        if rootPart and point then
            rootPart.CFrame = point.CFrame + Vector3.new(0, 3, 0)
        end

        local entry = { model = clone, data = mobData }
        table.insert(activeMobs, entry)

        -- Remove da lista quando morrer
        if humanoid then
            humanoid.Died:Connect(function()
                for idx, v in activeMobs do
                    if v.model == clone then
                        table.remove(activeMobs, idx)
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
