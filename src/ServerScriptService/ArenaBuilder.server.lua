-- ArenaBuilder.server.lua
-- 🏟️ Constrói o Allianz Brainrot Arena em runtime
-- Gera os 4 andares, teleportes, spawn points e a loja dourada do Nathan

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

-- ============================================================
-- Constantes de layout
-- ============================================================
local FLOOR_WIDTH   = 120
local FLOOR_DEPTH   = 120
local FLOOR_THICK   = 4
local WALL_HEIGHT   = 28
local WALL_THICK    = 3

-- ============================================================
-- Utilitários de criação de peças
-- ============================================================

local function makePart(parent, name, size, cframe, color, material, anchored)
    local p = Instance.new("Part")
    p.Name      = name
    p.Size      = size
    p.CFrame    = cframe
    p.BrickColor= BrickColor.new(color or "Medium stone grey")
    p.Material  = material or Enum.Material.SmoothPlastic
    p.Anchored  = anchored ~= false
    p.Parent    = parent
    return p
end

local function addLabel(part, text, color)
    local sg = Instance.new("SurfaceGui")
    sg.Face   = Enum.NormalId.Top
    sg.Parent = part
    local lbl = Instance.new("TextLabel")
    lbl.Size              = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = text
    lbl.TextColor3        = color or Color3.fromRGB(255,255,255)
    lbl.Font              = Enum.Font.GothamBold
    lbl.TextScaled        = true
    lbl.Parent            = sg
end

-- ============================================================
-- Spawn points para mobs num andar
-- ============================================================

local function createSpawnPoints(floorFolder, baseY, floorId)
    local spawnFolder = Instance.new("Folder")
    spawnFolder.Name = "SpawnPoints_Floor" .. floorId
    spawnFolder.Parent = workspace

    local offsets = {
        Vector3.new( 45, 0,  45),
        Vector3.new(-45, 0,  45),
        Vector3.new( 45, 0, -45),
        Vector3.new(-45, 0, -45),
        Vector3.new(  0, 0,  50),
        Vector3.new(  0, 0, -50),
        Vector3.new( 50, 0,   0),
        Vector3.new(-50, 0,   0),
    }
    for i, offset in offsets do
        local sp = Instance.new("Part")
        sp.Name      = "SpawnPoint_" .. i
        sp.Size      = Vector3.new(2, 0.1, 2)
        sp.CFrame    = CFrame.new(offset + Vector3.new(0, baseY + FLOOR_THICK/2 + 0.1, 0))
        sp.Anchored  = true
        sp.CanCollide = false
        sp.Transparency = 0.8
        sp.BrickColor = BrickColor.new("Bright green")
        sp.Parent    = spawnFolder
    end
    return spawnFolder
end

-- ============================================================
-- Teleporte entre andares
-- ============================================================

local function createElevator(baseY, targetY, label)
    local pos = Vector3.new(52, baseY + FLOOR_THICK + 2, 0)

    local pad = makePart(workspace, "Elevator_" .. label,
        Vector3.new(6, 1, 6),
        CFrame.new(pos),
        "Bright yellow", Enum.Material.Neon)

    -- Texto no pad
    local sg = Instance.new("SurfaceGui")
    sg.Face  = Enum.NormalId.Top
    sg.Parent = pad
    local lbl = Instance.new("TextLabel")
    lbl.Size  = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text  = label
    lbl.TextColor3 = Color3.fromRGB(0,0,0)
    lbl.Font  = Enum.Font.GothamBold
    lbl.TextScaled = true
    lbl.Parent = sg

    -- Toca o teleporte ao pisar
    pad.Touched:Connect(function(hit)
        local character = hit.Parent
        local player = Players:GetPlayerFromCharacter(character)
        if not player then return end

        local profile = player:FindFirstChild("PlayerProfile")
        local unlocked = profile and profile:FindFirstChild("UnlockedFloors")

        -- extrai ID do andar destino do label ("▲ Andar 2")
        local floorNum = tonumber(label:match("%d+"))
        if not floorNum then return end

        local allowed = false
        if floorNum == 1 then
            allowed = true
        elseif unlocked and unlocked:FindFirstChild("Floor_" .. floorNum) then
            allowed = true
        end

        -- Nathan passa em tudo
        local isCreator = profile and profile:FindFirstChild("IsCreator") and profile.IsCreator.Value
        if isCreator then allowed = true end

        if allowed then
            local root = character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = CFrame.new(Vector3.new(0, targetY + FLOOR_THICK + 5, 0))
            end
        else
            -- Feedback visual: pad pisca vermelho
            local orig = pad.BrickColor
            pad.BrickColor = BrickColor.new("Bright red")
            task.delay(1, function() pad.BrickColor = orig end)

            local Remotes = ReplicatedStorage:WaitForChild("Remotes")
            if Remotes:FindFirstChild("GlobalAnnounce") then
                Remotes.GlobalAnnounce:FireClient(player,
                    "🔒 Desbloqueie este andar na loja!",
                    Color3.fromRGB(255, 60, 60))
            end
        end
    end)

    return pad
end

-- ============================================================
-- Loja Dourada do Nathan (Andar 1)
-- ============================================================

local function buildNathanShop(baseY)
    local shopFolder = Instance.new("Folder")
    shopFolder.Name  = "NathanShop"
    shopFolder.Parent = workspace

    -- Balcão
    local counter = makePart(shopFolder, "Counter",
        Vector3.new(12, 2, 4),
        CFrame.new(Vector3.new(-50, baseY + FLOOR_THICK + 1, 0)),
        "Bright yellow", Enum.Material.Neon)

    -- Telhado decorativo
    local roof = makePart(shopFolder, "ShopRoof",
        Vector3.new(14, 0.5, 6),
        CFrame.new(Vector3.new(-50, baseY + FLOOR_THICK + 8, 0)),
        "Bright yellow", Enum.Material.Neon)

    -- Paredes laterais
    makePart(shopFolder, "Wall_L", Vector3.new(0.5, 7, 6),
        CFrame.new(Vector3.new(-44, baseY + FLOOR_THICK + 3.5, 0)),
        "Medium stone grey")
    makePart(shopFolder, "Wall_R", Vector3.new(0.5, 7, 6),
        CFrame.new(Vector3.new(-56, baseY + FLOOR_THICK + 3.5, 0)),
        "Medium stone grey")

    -- Sinalização neon
    local sign = makePart(shopFolder, "ShopSign",
        Vector3.new(10, 2, 0.3),
        CFrame.new(Vector3.new(-50, baseY + FLOOR_THICK + 10, 0)),
        "Bright yellow", Enum.Material.Neon)
    local sg = Instance.new("SurfaceGui") sg.Face = Enum.NormalId.Front sg.Parent = sign
    local signLabel = Instance.new("TextLabel")
    signLabel.Size = UDim2.new(1,0,1,0)
    signLabel.BackgroundTransparency = 1
    signLabel.Text = "⭐ LOJA DO NATHAN ⭐"
    signLabel.TextColor3 = Color3.fromRGB(0,0,0)
    signLabel.Font = Enum.Font.GothamBold
    signLabel.TextScaled = true
    signLabel.Parent = sg

    -- Trigger de abertura da loja
    local trigger = makePart(shopFolder, "ShopTrigger",
        Vector3.new(14, 6, 6),
        CFrame.new(Vector3.new(-50, baseY + FLOOR_THICK + 3, 0)))
    trigger.Transparency = 1
    trigger.CanCollide   = false

    trigger.Touched:Connect(function(hit)
        local character = hit.Parent
        local player = Players:GetPlayerFromCharacter(character)
        if not player then return end

        local Remotes = ReplicatedStorage:WaitForChild("Remotes")
        if Remotes:FindFirstChild("OpenShop") then
            Remotes.OpenShop:FireClient(player)
        end
    end)

    return shopFolder
end

-- ============================================================
-- Construção dos andares
-- ============================================================

local function buildFloor(floorData)
    local baseY = floorData.spawnHeight
    local folder = Instance.new("Folder")
    folder.Name  = "Floor_" .. floorData.id
    folder.Parent = workspace

    -- Piso principal
    local floor = makePart(folder, "Floor",
        Vector3.new(FLOOR_WIDTH, FLOOR_THICK, FLOOR_DEPTH),
        CFrame.new(0, baseY, 0),
        "Light stone grey", Enum.Material.SmoothPlastic)

    -- Linha verde do campo (decoração do Allianz Park)
    makePart(folder, "FieldLine_Center",
        Vector3.new(FLOOR_WIDTH, 0.1, 2),
        CFrame.new(0, baseY + FLOOR_THICK/2 + 0.05, 0),
        "Bright green", Enum.Material.Neon)

    -- Paredes
    -- Norte
    makePart(folder, "Wall_N", Vector3.new(FLOOR_WIDTH, WALL_HEIGHT, WALL_THICK),
        CFrame.new(0, baseY + WALL_HEIGHT/2, -FLOOR_DEPTH/2 - WALL_THICK/2))
    -- Sul
    makePart(folder, "Wall_S", Vector3.new(FLOOR_WIDTH, WALL_HEIGHT, WALL_THICK),
        CFrame.new(0, baseY + WALL_HEIGHT/2, FLOOR_DEPTH/2 + WALL_THICK/2))
    -- Leste
    makePart(folder, "Wall_E", Vector3.new(WALL_THICK, WALL_HEIGHT, FLOOR_DEPTH),
        CFrame.new(FLOOR_WIDTH/2 + WALL_THICK/2, baseY + WALL_HEIGHT/2, 0))
    -- Oeste
    makePart(folder, "Wall_W", Vector3.new(WALL_THICK, WALL_HEIGHT, FLOOR_DEPTH),
        CFrame.new(-FLOOR_WIDTH/2 - WALL_THICK/2, baseY + WALL_HEIGHT/2, 0))

    -- Label decorativo no chão
    addLabel(floor, floorData.name, floorData.color)

    -- Spawn points
    createSpawnPoints(folder, baseY, floorData.id)

    -- Elevadores para o andar acima (se houver)
    local nextFloor = GameConfig.FLOORS[floorData.id + 1]
    if nextFloor then
        createElevator(baseY, nextFloor.spawnHeight, "▲ Andar " .. nextFloor.id)
    end
    -- Elevador de retorno para o andar abaixo (se não for o 1)
    if floorData.id > 1 then
        local prevFloor = GameConfig.FLOORS[floorData.id - 1]
        local returnPad = makePart(workspace, "Return_" .. floorData.id,
            Vector3.new(6, 1, 6),
            CFrame.new(Vector3.new(-52, baseY + FLOOR_THICK + 2, 0)),
            "Cyan", Enum.Material.Neon)
        local sg2 = Instance.new("SurfaceGui") sg2.Face = Enum.NormalId.Top sg2.Parent = returnPad
        local lbl2 = Instance.new("TextLabel")
        lbl2.Size = UDim2.new(1,0,1,0) lbl2.BackgroundTransparency = 1
        lbl2.Text = "▼ Andar " .. prevFloor.id lbl2.Font = Enum.Font.GothamBold
        lbl2.TextColor3 = Color3.fromRGB(0,0,0) lbl2.TextScaled = true lbl2.Parent = sg2
        returnPad.Touched:Connect(function(hit)
            local char = hit.Parent
            local p = Players:GetPlayerFromCharacter(char)
            if not p then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = CFrame.new(Vector3.new(0, prevFloor.spawnHeight + FLOOR_THICK + 5, 0))
            end
        end)
    end

    return folder
end

-- ============================================================
-- Construção geral
-- ============================================================

local function buildArena()
    print("[ArenaBuilder] Construindo Allianz Brainrot Arena...")

    -- Limpa qualquer lixo anterior
    for _, name in {"Floor_1","Floor_2","Floor_3","Floor_4","NathanShop","SpawnPoints_Floor1"} do
        local obj = workspace:FindFirstChild(name)
        if obj then obj:Destroy() end
    end

    for _, floorData in GameConfig.FLOORS do
        buildFloor(floorData)
    end

    -- Loja dourada no Andar 1
    buildNathanShop(GameConfig.FLOORS[1].spawnHeight)

    -- Espaço do céu: uma luz ambiente suave
    game.Lighting.Ambient            = Color3.fromRGB(80, 80, 80)
    game.Lighting.OutdoorAmbient     = Color3.fromRGB(100, 100, 100)
    game.Lighting.Brightness         = 1.5
    game.Lighting.GlobalShadows      = true

    print("[ArenaBuilder] Arena construída com " .. #GameConfig.FLOORS .. " andares!")
end

buildArena()
