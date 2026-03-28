-- MobSpawner.lua
-- Spawna e gerencia os mobs de brainrot por onda
-- Allianz Brainrot Arena — inclui mobs novos (Elefante Morango, Porco Dourado, etc.)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local MobData = require(ReplicatedStorage.Shared.MobData)

local MobSpawner = {}

local activeMobs = {}

-- Tabela de mobs disponíveis no jogo (referencia nomes de modelos em ReplicatedStorage.Mobs)
local MOB_POOL = {
    -- Comum (total weight ~54)
    { name = "Tralalero",         weight = 14, baseHp = 100, speed = 16 },
    { name = "BonecaAmbalabu",    weight = 12, baseHp = 80,  speed = 18 },
    { name = "FrigoCamelo",       weight = 10, baseHp = 120, speed = 14 },
    { name = "SalminoPinguino",   weight = 8,  baseHp = 90,  speed = 20 },
    { name = "MorangoFilhote",    weight = 10, baseHp = 70,  speed = 22 },
    -- Incomum (total weight ~34)
    { name = "BombardinoCoccodrillo", weight = 7, baseHp = 200, speed = 12 },
    { name = "TungTungSahur",     weight = 6, baseHp = 150, speed = 18 },
    { name = "ChimpanziniBananini", weight = 6, baseHp = 180, speed = 16 },
    { name = "BallerinaCappuccina", weight = 5, baseHp = 160, speed = 14 },
    { name = "DinoVerde",         weight = 5, baseHp = 170, speed = 17 },
    { name = "AnjoBrainrotMini",  weight = 5, baseHp = 140, speed = 20 },
    -- Raro (total weight ~16)
    { name = "CappuccinoAssassino", weight = 4, baseHp = 400, speed = 10 },
    { name = "GlorboFruttodrillo",  weight = 4, baseHp = 350, speed = 11 },
    { name = "LaVacaSaturno",       weight = 3, baseHp = 500, speed = 8 },
    { name = "ElefanteMorango",     weight = 5, baseHp = 600, speed = 9 },
    -- Epico (total weight ~10)
    { name = "LiriliLarila",      weight = 2, baseHp = 800,  speed = 8 },
    { name = "TrippiTroppi",      weight = 2, baseHp = 700,  speed = 10 },
    { name = "BobritoFrittomisto", weight = 2, baseHp = 1000, speed = 7 },
    { name = "CrocodiloDourado",  weight = 2, baseHp = 1200, speed = 7 },
    { name = "AnjoBrainrot",      weight = 2, baseHp = 900,  speed = 12 },
    -- Lendario (boss - spawna em rodadas altas)
    { name = "BrioBranta",        weight = 1, baseHp = 2000, speed = 6 },
    { name = "PorcoDourado",      weight = 1, baseHp = 3000, speed = 5 },
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

    -- Busca dados visuais do MobData
    local mobInfo = MobData.get(mobData.name)
    local bodyColor = mobInfo and mobInfo.bodyColor or Color3.fromRGB(200, 50, 50)
    local headColor = mobInfo and mobInfo.headColor or Color3.fromRGB(255, 200, 50)
    local hasWings = mobInfo and mobInfo.hasWings or false
    local isBoss = mobInfo and mobInfo.isBoss or false

    local rootPart = Instance.new("Part")
    rootPart.Name = "HumanoidRootPart"
    rootPart.Size = isBoss and Vector3.new(4, 6, 4) or Vector3.new(2, 4, 2)
    rootPart.Anchored = false
    rootPart.CanCollide = true
    rootPart.Color = bodyColor
    rootPart.Material = Enum.Material.SmoothPlastic
    rootPart.Parent = model

    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = isBoss and Vector3.new(3, 2, 2) or Vector3.new(2, 1, 1)
    head.Position = rootPart.Position + Vector3.new(0, isBoss and 4.5 or 2.5, 0)
    head.Anchored = false
    head.CanCollide = true
    head.Color = headColor
    head.Material = Enum.Material.SmoothPlastic
    head.Parent = model

    -- Boss: brilho dourado
    if isBoss then
        local glow = Instance.new("PointLight")
        glow.Range = 25
        glow.Brightness = 2
        glow.Color = Color3.fromRGB(255, 215, 0)
        glow.Parent = rootPart

        -- Particulas douradas
        local particles = Instance.new("ParticleEmitter")
        particles.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
        particles.Size = NumberSequence.new(0.5)
        particles.Lifetime = NumberRange.new(1, 2)
        particles.Rate = 5
        particles.Speed = NumberRange.new(2, 5)
        particles.SpreadAngle = Vector2.new(180, 180)
        particles.LightEmission = 0.6
        particles.Parent = rootPart
    end

    -- Asas para mobs anjo
    if hasWings then
        local wingL = Instance.new("Part")
        wingL.Name = "WingLeft"
        wingL.Size = Vector3.new(0.2, 3, 2)
        wingL.Position = rootPart.Position + Vector3.new(-1.5, 1.5, -0.5)
        wingL.Anchored = false
        wingL.CanCollide = false
        wingL.Color = Color3.fromRGB(220, 255, 220)
        wingL.Material = Enum.Material.Neon
        wingL.Transparency = 0.3
        wingL.Parent = model

        local wingR = Instance.new("Part")
        wingR.Name = "WingRight"
        wingR.Size = Vector3.new(0.2, 3, 2)
        wingR.Position = rootPart.Position + Vector3.new(1.5, 1.5, -0.5)
        wingR.Anchored = false
        wingR.CanCollide = false
        wingR.Color = Color3.fromRGB(220, 255, 220)
        wingR.Material = Enum.Material.Neon
        wingR.Transparency = 0.3
        wingR.Parent = model

        -- Aureola
        local halo = Instance.new("Part")
        halo.Name = "Halo"
        halo.Shape = Enum.PartType.Cylinder
        halo.Size = Vector3.new(0.15, 2.5, 2.5)
        halo.Position = head.Position + Vector3.new(0, 1.5, 0)
        halo.Orientation = Vector3.new(0, 0, 90)
        halo.Anchored = false
        halo.CanCollide = false
        halo.Color = Color3.fromRGB(255, 255, 100)
        halo.Material = Enum.Material.Neon
        halo.Parent = model
    end

    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = model

    -- Nametag
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Nametag"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, isBoss and 5 or 3, 0)
    billboard.Adornee = head
    billboard.Parent = head

    -- Rarity color for nametag
    local rarityColors = {
        comum = Color3.fromRGB(200, 200, 200),
        incomum = Color3.fromRGB(0, 200, 0),
        raro = Color3.fromRGB(50, 100, 255),
        epico = Color3.fromRGB(200, 50, 255),
        lendario = Color3.fromRGB(255, 215, 0),
    }
    local displayName = mobInfo and mobInfo.displayName or mobData.name
    local rarity = mobInfo and mobInfo.rarity or "comum"
    local nameColor = rarityColors[rarity] or Color3.fromRGB(255, 50, 50)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = displayName
    nameLabel.TextColor3 = nameColor
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
