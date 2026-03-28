-- StadiumBuilder.server.lua
-- Constroi o Allianz Brainrot Arena: campo, gols, arquibancadas Palmeiras,
-- arco de entrada, NPCs brainrot, mini-games, loja, decoracoes, moedas

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local S = GameConfig.STADIUM
local FIELD_L = S.FIELD_LENGTH  -- 160
local FIELD_W = S.FIELD_WIDTH   -- 100
local FIELD_Y = S.FIELD_Y       -- 0
local STAND_H = S.STAND_HEIGHT  -- 20
local STAND_ROWS = S.STAND_ROWS -- 5

-- ============================================================
-- Utilidades
-- ============================================================

local function part(parent, name, size, cframe, color, material)
    local p = Instance.new("Part")
    p.Name      = name
    p.Size      = size
    p.CFrame    = cframe
    p.BrickColor = BrickColor.new(color or "Medium stone grey")
    p.Material  = material or Enum.Material.SmoothPlastic
    p.Anchored  = true
    p.Parent    = parent
    return p
end

local function label(p, text, color, face)
    local sg = Instance.new("SurfaceGui")
    sg.Face = face or Enum.NormalId.Top
    sg.Parent = p
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color or Color3.fromRGB(255,255,255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextScaled = true
    lbl.Parent = sg
end

local function billboard(parent, text, color, offset)
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 220, 0, 50)
    bb.StudsOffset = offset or Vector3.new(0, 4, 0)
    bb.Adornee = parent
    bb.AlwaysOnTop = false
    bb.MaxDistance = 80
    bb.Parent = parent
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundColor3 = Color3.fromRGB(15,15,20)
    lbl.BackgroundTransparency = 0.3
    lbl.TextColor3 = color or Color3.fromRGB(255,255,255)
    lbl.Text = text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 16
    lbl.TextStrokeTransparency = 0.3
    lbl.Parent = bb
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 8)
    return bb
end

-- ============================================================
-- Limpa construcao anterior
-- ============================================================
local function cleanup()
    local names = {
        "Stadium", "FootballField", "Stands_N", "Stands_S", "Stands_E", "Stands_W",
        "Goals", "NathanShop", "FootballPitch", "SpawnPoints_Floor1",
        "MinigameZones", "StadiumNPCs", "StadiumDecorations", "EntranceArch",
        "Floor_1", "Floor_2", "Floor_3", "Floor_4", "CoinRain",
    }
    for _, n in names do
        local obj = workspace:FindFirstChild(n)
        if obj then obj:Destroy() end
    end
    -- Also remove old spawn point folders
    for _, child in workspace:GetChildren() do
        if child:IsA("Folder") and child.Name:match("^SpawnPoints") then
            child:Destroy()
        end
    end
end

-- ============================================================
-- GRAMADO (campo de futebol completo)
-- ============================================================
local function buildField(folder)
    local fy = FIELD_Y + 0.05

    -- Gramado principal (verde escuro com textura)
    local grass = part(folder, "Grass",
        Vector3.new(FIELD_L, 0.5, FIELD_W),
        CFrame.new(0, FIELD_Y, 0),
        "Dark green", Enum.Material.Grass)
    grass.TopSurface = Enum.SurfaceType.Smooth

    -- Faixas de gramado alternadas (efeito de corte de grama)
    local stripeW = FIELD_W
    local stripeCount = 10
    local stripeLen = FIELD_L / stripeCount
    for i = 0, stripeCount - 1 do
        if i % 2 == 0 then
            local stripe = part(folder, "GrassStripe_"..i,
                Vector3.new(stripeLen - 0.2, 0.02, stripeW - 0.2),
                CFrame.new(-FIELD_L/2 + stripeLen/2 + i*stripeLen, fy + 0.02, 0),
                "Bright green", Enum.Material.Grass)
            stripe.Transparency = 0.3
        end
    end

    -- Linhas do campo
    local LT = 0.12  -- line thickness (Y)
    local LW = 0.4   -- line width

    -- Linhas laterais
    part(folder, "LineN", Vector3.new(FIELD_L, LT, LW), CFrame.new(0, fy, -FIELD_W/2), "White")
    part(folder, "LineS", Vector3.new(FIELD_L, LT, LW), CFrame.new(0, fy, FIELD_W/2), "White")
    part(folder, "LineE", Vector3.new(LW, LT, FIELD_W), CFrame.new(FIELD_L/2, fy, 0), "White")
    part(folder, "LineW", Vector3.new(LW, LT, FIELD_W), CFrame.new(-FIELD_L/2, fy, 0), "White")

    -- Linha central
    part(folder, "LineCentral", Vector3.new(LW, LT, FIELD_W), CFrame.new(0, fy, 0), "White")

    -- Circulo central
    local radius = 12
    local segs = 24
    for i = 1, segs do
        local a1 = (i-1) * (2*math.pi/segs)
        local a2 = i * (2*math.pi/segs)
        local x1, z1 = math.cos(a1)*radius, math.sin(a1)*radius
        local x2, z2 = math.cos(a2)*radius, math.sin(a2)*radius
        local mx, mz = (x1+x2)/2, (z1+z2)/2
        local len = math.sqrt((x2-x1)^2 + (z2-z1)^2)
        local angle = math.atan2(x2-x1, z2-z1)
        part(folder, "Circle_"..i,
            Vector3.new(LW, LT, len),
            CFrame.new(mx, fy, mz) * CFrame.Angles(0, angle, 0),
            "White")
    end

    -- Ponto central
    part(folder, "CenterSpot", Vector3.new(1.5, LT+0.02, 1.5), CFrame.new(0, fy, 0), "White")

    -- Areas de penalti (ambos os lados)
    local PA_W = 40  -- penalty area width (Z)
    local PA_D = 22  -- penalty area depth (X from goal line)

    for _, side in {{ x = -FIELD_L/2, dir = 1 }, { x = FIELD_L/2, dir = -1 }} do
        local px = side.x + side.dir * PA_D
        part(folder, "Penalty_Top", Vector3.new(PA_D, LT, LW), CFrame.new((side.x + px)/2, fy, -PA_W/2), "White")
        part(folder, "Penalty_Bot", Vector3.new(PA_D, LT, LW), CFrame.new((side.x + px)/2, fy, PA_W/2), "White")
        part(folder, "Penalty_Front", Vector3.new(LW, LT, PA_W), CFrame.new(px, fy, 0), "White")

        -- Ponto de penalti
        local penX = side.x + side.dir * 14
        part(folder, "PenaltySpot", Vector3.new(1, LT+0.02, 1), CFrame.new(penX, fy, 0), "White")
    end

    -- Gols
    local GOAL_W = 14
    local GOAL_H = 7
    local GOAL_D = 4
    local POST = 0.5

    local goalsFolder = Instance.new("Folder")
    goalsFolder.Name = "Goals"
    goalsFolder.Parent = folder

    for _, side in {{ x = -FIELD_L/2, dir = 1, name = "W" }, { x = FIELD_L/2, dir = -1, name = "E" }} do
        -- Trave esquerda
        part(goalsFolder, "Post_"..side.name.."_L",
            Vector3.new(POST, GOAL_H, POST),
            CFrame.new(side.x, fy + GOAL_H/2, -GOAL_W/2),
            "White", Enum.Material.Metal)
        -- Trave direita
        part(goalsFolder, "Post_"..side.name.."_R",
            Vector3.new(POST, GOAL_H, POST),
            CFrame.new(side.x, fy + GOAL_H/2, GOAL_W/2),
            "White", Enum.Material.Metal)
        -- Travessao
        part(goalsFolder, "Bar_"..side.name,
            Vector3.new(POST, POST, GOAL_W),
            CFrame.new(side.x, fy + GOAL_H, 0),
            "White", Enum.Material.Metal)
        -- Rede
        local net = part(goalsFolder, "Net_"..side.name,
            Vector3.new(GOAL_D, GOAL_H, GOAL_W),
            CFrame.new(side.x + side.dir*GOAL_D/2, fy + GOAL_H/2, 0),
            "White", Enum.Material.ForceField)
        net.Transparency = 0.7
        net.CanCollide = false
        -- GoalTrigger
        local trigger = Instance.new("Part")
        trigger.Name = "GoalTrigger_"..side.name
        trigger.Size = Vector3.new(2, GOAL_H, GOAL_W - 1)
        trigger.CFrame = CFrame.new(side.x, fy + GOAL_H/2, 0)
        trigger.Transparency = 1
        trigger.CanCollide = false
        trigger.Anchored = true
        trigger.Parent = goalsFolder
    end

    return folder
end

-- ============================================================
-- ARQUIBANCADAS (4 lados com assentos coloridos)
-- ============================================================
local function buildStands(parent)
    -- Palmeiras: verde e branco alternados
    local seatColors = {"Dark green", "White", "Bright green", "White", "Forest green"}
    local rowDepth = 4
    local rowHeight = 3

    -- Arquibancada Norte e Sul (ao longo do comprimento)
    for _, sideData in {
        { name = "N", z = -FIELD_W/2 - 8, zDir = -1 },
        { name = "S", z =  FIELD_W/2 + 8, zDir =  1 },
    } do
        local standFolder = Instance.new("Folder")
        standFolder.Name = "Stands_"..sideData.name
        standFolder.Parent = parent

        for row = 0, STAND_ROWS - 1 do
            local y = FIELD_Y + row * rowHeight
            local z = sideData.z + sideData.zDir * row * rowDepth
            local color = seatColors[(row % #seatColors) + 1]

            -- Estrutura da fileira (concreto)
            part(standFolder, "StandRow_"..row,
                Vector3.new(FIELD_L + 20, rowHeight, rowDepth),
                CFrame.new(0, y + rowHeight/2, z),
                "Medium stone grey", Enum.Material.Concrete)

            -- Assentos coloridos em cima
            local seatPart = part(standFolder, "Seats_"..row,
                Vector3.new(FIELD_L + 18, 0.5, rowDepth - 0.5),
                CFrame.new(0, y + rowHeight + 0.25, z),
                color, Enum.Material.SmoothPlastic)

            -- A cada X studs, coloca um "torcedor brainrot" (part decorativa)
            if row < 3 then
                for sx = -FIELD_L/2, FIELD_L/2, 12 do
                    local fan = part(standFolder, "Fan",
                        Vector3.new(1.5, 3, 1.5),
                        CFrame.new(sx + math.random(-2,2), y + rowHeight + 2, z),
                        seatColors[math.random(1, #seatColors)])
                    fan.Shape = Enum.PartType.Cylinder
                    fan.Orientation = Vector3.new(0, 0, 90)

                    -- Cabeca do torcedor
                    local head = part(standFolder, "FanHead",
                        Vector3.new(1.2, 1.2, 1.2),
                        CFrame.new(sx + math.random(-2,2), y + rowHeight + 4, z),
                        "Pastel brown")
                    head.Shape = Enum.PartType.Ball
                end
            end
        end
    end

    -- Arquibancada Leste e Oeste (atras dos gols, mais curtas)
    for _, sideData in {
        { name = "E", x =  FIELD_L/2 + 12, xDir =  1 },
        { name = "W", x = -FIELD_L/2 - 12, xDir = -1 },
    } do
        local standFolder = Instance.new("Folder")
        standFolder.Name = "Stands_"..sideData.name
        standFolder.Parent = parent

        for row = 0, STAND_ROWS - 1 do
            local y = FIELD_Y + row * rowHeight
            local x = sideData.x + sideData.xDir * row * rowDepth
            local color = seatColors[(row % #seatColors) + 1]

            part(standFolder, "StandRow_"..row,
                Vector3.new(rowDepth, rowHeight, FIELD_W - 10),
                CFrame.new(x, y + rowHeight/2, 0),
                "Medium stone grey", Enum.Material.Concrete)

            part(standFolder, "Seats_"..row,
                Vector3.new(rowDepth - 0.5, 0.5, FIELD_W - 12),
                CFrame.new(x, y + rowHeight + 0.25, 0),
                color, Enum.Material.SmoothPlastic)
        end
    end
end

-- ============================================================
-- SPAWN POINTS (espalhados pelo campo)
-- ============================================================
local function createSpawnPoints(parent)
    local spawnFolder = Instance.new("Folder")
    spawnFolder.Name = "SpawnPoints_Floor1"
    spawnFolder.Parent = workspace

    local offsets = {
        Vector3.new( 50, 0,  30),
        Vector3.new(-50, 0,  30),
        Vector3.new( 50, 0, -30),
        Vector3.new(-50, 0, -30),
        Vector3.new( 25, 0,  0),
        Vector3.new(-25, 0,  0),
        Vector3.new( 0,  0,  35),
        Vector3.new( 0,  0, -35),
        Vector3.new( 65, 0,  15),
        Vector3.new(-65, 0, -15),
        Vector3.new( 35, 0,  40),
        Vector3.new(-35, 0, -40),
    }

    for i, off in offsets do
        local sp = Instance.new("Part")
        sp.Name = "SpawnPoint_"..i
        sp.Size = Vector3.new(2, 0.1, 2)
        sp.CFrame = CFrame.new(off + Vector3.new(0, FIELD_Y + 0.5, 0))
        sp.Anchored = true
        sp.CanCollide = false
        sp.Transparency = 0.9
        sp.BrickColor = BrickColor.new("Bright green")
        sp.Parent = spawnFolder
    end
end

-- ============================================================
-- LOJA DO NATHAN (lateral do campo)
-- ============================================================
local function buildShop(parent)
    local shopFolder = Instance.new("Folder")
    shopFolder.Name = "NathanShop"
    shopFolder.Parent = parent

    local shopX = -FIELD_L/2 - 6
    local shopZ = 0
    local shopY = FIELD_Y

    -- Barraca da loja (verde e dourado Palmeiras)
    local floor = part(shopFolder, "ShopFloor",
        Vector3.new(10, 0.5, 14),
        CFrame.new(shopX, shopY + 0.25, shopZ),
        "Bright green", Enum.Material.Neon)

    -- Balcao
    local counter = part(shopFolder, "Counter",
        Vector3.new(8, 2.5, 2),
        CFrame.new(shopX, shopY + 1.75, shopZ + 5),
        "Gold", Enum.Material.Glass)

    -- Telhado
    local roof = part(shopFolder, "Roof",
        Vector3.new(12, 0.5, 16),
        CFrame.new(shopX, shopY + 8, shopZ),
        "Dark green", Enum.Material.SmoothPlastic)

    -- Pilares
    for _, offset in {Vector3.new(-5, 0, -6), Vector3.new(5, 0, -6), Vector3.new(-5, 0, 6), Vector3.new(5, 0, 6)} do
        part(shopFolder, "Pillar",
            Vector3.new(0.8, 8, 0.8),
            CFrame.new(shopX + offset.X, shopY + 4, shopZ + offset.Z),
            "Medium stone grey", Enum.Material.Metal)
    end

    -- Letreiro
    local sign = part(shopFolder, "Sign",
        Vector3.new(10, 2, 0.4),
        CFrame.new(shopX, shopY + 9.5, shopZ),
        "Gold", Enum.Material.Neon)
    label(sign, "LOJA DO PORCO DOURADO", Color3.fromRGB(0,80,0), Enum.NormalId.Front)
    label(sign, "LOJA DO PORCO DOURADO", Color3.fromRGB(0,80,0), Enum.NormalId.Back)

    -- Trigger
    local trigger = part(shopFolder, "ShopTrigger",
        Vector3.new(12, 8, 16),
        CFrame.new(shopX, shopY + 4, shopZ))
    trigger.Transparency = 1
    trigger.CanCollide = false

    trigger.Touched:Connect(function(hit)
        local character = hit.Parent
        local player = Players:GetPlayerFromCharacter(character)
        if not player then return end
        local Remotes = ReplicatedStorage:WaitForChild("Remotes")
        if Remotes:FindFirstChild("OpenShop") then
            Remotes.OpenShop:FireClient(player)
        end
    end)
end

-- ============================================================
-- MINI-GAME ZONES (plataformas espalhadas com triggers)
-- ============================================================
local function buildMinigameZones(parent)
    local zonesFolder = Instance.new("Folder")
    zonesFolder.Name = "MinigameZones"
    zonesFolder.Parent = parent

    for _, mg in GameConfig.MINIGAMES do
        local pos = mg.position
        local zoneY = FIELD_Y

        -- Plataforma circular
        local platform = part(zonesFolder, "MG_"..mg.id,
            Vector3.new(10, 0.5, 10),
            CFrame.new(pos.X, zoneY + 0.3, pos.Z),
            "Cyan", Enum.Material.Neon)

        -- Circulo decorativo
        local ring = part(zonesFolder, "Ring_"..mg.id,
            Vector3.new(12, 0.1, 12),
            CFrame.new(pos.X, zoneY + 0.15, pos.Z),
            "Institutional white", Enum.Material.Neon)
        ring.Shape = Enum.PartType.Cylinder
        ring.Orientation = Vector3.new(0, 0, 90)
        ring.Transparency = 0.5

        -- Poste com letreiro
        local pole = part(zonesFolder, "Pole_"..mg.id,
            Vector3.new(0.5, 6, 0.5),
            CFrame.new(pos.X + 5, zoneY + 3, pos.Z),
            "Medium stone grey", Enum.Material.Metal)

        local signBoard = part(zonesFolder, "Sign_"..mg.id,
            Vector3.new(6, 2, 0.3),
            CFrame.new(pos.X + 5, zoneY + 7, pos.Z),
            "Really black")
        label(signBoard, mg.name, Color3.fromRGB(255, 215, 0), Enum.NormalId.Front)
        label(signBoard, mg.name, Color3.fromRGB(255, 215, 0), Enum.NormalId.Back)

        -- Billboard flutuante com descricao
        billboard(platform, mg.name.."\n"..mg.description, Color3.fromRGB(100, 255, 200), Vector3.new(0, 5, 0))

        -- Trigger de ativacao
        local trigger = Instance.new("Part")
        trigger.Name = "MinigameTrigger_"..mg.id
        trigger.Size = Vector3.new(10, 6, 10)
        trigger.CFrame = CFrame.new(pos.X, zoneY + 3, pos.Z)
        trigger.Transparency = 1
        trigger.CanCollide = false
        trigger.Anchored = true
        trigger.Parent = zonesFolder

        -- Cones/obstaculos decorativos ao redor
        for j = 1, 4 do
            local angle = (j-1) * (math.pi/2) + math.pi/4
            local cx = pos.X + math.cos(angle) * 7
            local cz = pos.Z + math.sin(angle) * 7
            local cone = part(zonesFolder, "Cone",
                Vector3.new(1, 2, 1),
                CFrame.new(cx, zoneY + 1, cz),
                "Neon orange", Enum.Material.Neon)
        end
    end
end

-- ============================================================
-- BRAINROT NPCs (interativos espalhados)
-- ============================================================
local function buildNPCs(parent)
    local npcFolder = Instance.new("Folder")
    npcFolder.Name = "StadiumNPCs"
    npcFolder.Parent = parent

    for _, npcData in GameConfig.STADIUM_NPCS do
        local pos = npcData.pos
        local model = Instance.new("Model")
        model.Name = npcData.name

        -- Corpo
        local torso = Instance.new("Part")
        torso.Name = "HumanoidRootPart"
        torso.Size = Vector3.new(2, 4, 2)
        torso.CFrame = CFrame.new(pos.X, FIELD_Y + 2.5, pos.Z)
        torso.Anchored = true
        torso.CanCollide = true
        torso.BrickColor = BrickColor.new(npcData.color)
        torso.Material = Enum.Material.SmoothPlastic
        torso.Parent = model

        -- Cabeca
        local head = Instance.new("Part")
        head.Name = "Head"
        head.Size = Vector3.new(1.8, 1.8, 1.8)
        head.Shape = Enum.PartType.Ball
        head.CFrame = CFrame.new(pos.X, FIELD_Y + 5.4, pos.Z)
        head.Anchored = true
        head.CanCollide = true
        head.BrickColor = BrickColor.new("Pastel brown")
        head.Material = Enum.Material.SmoothPlastic
        head.Parent = model

        -- Face decal
        local face = Instance.new("Decal")
        face.Face = Enum.NormalId.Front
        face.Color3 = Color3.fromRGB(0,0,0)
        face.Parent = head

        model.PrimaryPart = torso
        model.Parent = npcFolder

        -- Nametag
        billboard(head, npcData.name, Color3.fromRGB(255, 200, 0), Vector3.new(0, 2, 0))

        -- Acao especial baseada em npcData.action
        if npcData.action == "cheer" then
            -- Torcedor pula periodicamente
            task.spawn(function()
                while torso.Parent do
                    local orig = torso.CFrame
                    torso.CFrame = orig + Vector3.new(0, 1.5, 0)
                    head.CFrame = head.CFrame + Vector3.new(0, 1.5, 0)
                    task.wait(0.3)
                    torso.CFrame = orig
                    head.CFrame = CFrame.new(pos.X, FIELD_Y + 5.4, pos.Z)
                    task.wait(math.random(2, 5))
                end
            end)
        elseif npcData.action == "sell" then
            -- Vendedor: abre loja ao tocar
            local sellTrigger = Instance.new("Part")
            sellTrigger.Name = "SellTrigger"
            sellTrigger.Size = Vector3.new(6, 6, 6)
            sellTrigger.CFrame = torso.CFrame
            sellTrigger.Transparency = 1
            sellTrigger.CanCollide = false
            sellTrigger.Anchored = true
            sellTrigger.Parent = npcFolder

            sellTrigger.Touched:Connect(function(hit)
                local player = Players:GetPlayerFromCharacter(hit.Parent)
                if not player then return end
                local Remotes = ReplicatedStorage:WaitForChild("Remotes")
                if Remotes:FindFirstChild("OpenShop") then
                    Remotes.OpenShop:FireClient(player)
                end
            end)
        elseif npcData.action == "whistle" then
            -- Arbitro gira no lugar
            task.spawn(function()
                local angle = 0
                while torso.Parent do
                    angle = angle + 2
                    torso.CFrame = CFrame.new(pos.X, FIELD_Y + 2.5, pos.Z) * CFrame.Angles(0, math.rad(angle), 0)
                    task.wait(0.05)
                end
            end)
        end
    end
end

-- ============================================================
-- DECORACOES ESPALHADAS
-- ============================================================
local function buildDecorations(parent)
    local decoFolder = Instance.new("Folder")
    decoFolder.Name = "StadiumDecorations"
    decoFolder.Parent = parent

    -- Placares de LED nos 4 cantos
    local corners = {
        { x = -FIELD_L/2 - 2, z = -FIELD_W/2 - 2 },
        { x =  FIELD_L/2 + 2, z = -FIELD_W/2 - 2 },
        { x = -FIELD_L/2 - 2, z =  FIELD_W/2 + 2 },
        { x =  FIELD_L/2 + 2, z =  FIELD_W/2 + 2 },
    }
    for i, corner in corners do
        -- Poste de refletor
        local pole = part(decoFolder, "LightPole_"..i,
            Vector3.new(1, 30, 1),
            CFrame.new(corner.x, FIELD_Y + 15, corner.z),
            "Medium stone grey", Enum.Material.Metal)

        -- Refletor
        local light = part(decoFolder, "Reflector_"..i,
            Vector3.new(4, 2, 4),
            CFrame.new(corner.x, FIELD_Y + 30.5, corner.z),
            "Institutional white", Enum.Material.Neon)

        local pl = Instance.new("PointLight")
        pl.Range = 80
        pl.Brightness = 2
        pl.Color = Color3.fromRGB(255, 250, 230)
        pl.Parent = light
    end

    -- Bandeirinhas de escanteio
    local cornerFlags = {
        Vector3.new(-FIELD_L/2, FIELD_Y, -FIELD_W/2),
        Vector3.new(-FIELD_L/2, FIELD_Y,  FIELD_W/2),
        Vector3.new( FIELD_L/2, FIELD_Y, -FIELD_W/2),
        Vector3.new( FIELD_L/2, FIELD_Y,  FIELD_W/2),
    }
    for i, pos in cornerFlags do
        local pole = part(decoFolder, "FlagPole_"..i,
            Vector3.new(0.2, 4, 0.2),
            CFrame.new(pos + Vector3.new(0, 2, 0)),
            "White", Enum.Material.Metal)
        local flag = part(decoFolder, "Flag_"..i,
            Vector3.new(0.1, 1.2, 1.8),
            CFrame.new(pos + Vector3.new(0, 3.5, 0.9)),
            "Bright red", Enum.Material.Fabric)
    end

    -- Telao gigante (atras do gol leste)
    local telao = part(decoFolder, "Telao",
        Vector3.new(0.5, 12, 24),
        CFrame.new(FIELD_L/2 + 28, FIELD_Y + 18, 0),
        "Really black", Enum.Material.Glass)
    label(telao, "ALLIANZ BRAINROT ARENA", Color3.fromRGB(255, 215, 0), Enum.NormalId.Back)

    -- Faixas decorativas penduradas — Palmeiras brainrot
    local bannerTexts = {"AVANTI PALESTRA!", "GOOOOL!", "BRAINROT!", "PORCO DOURADO!", "VERDAO!"}
    for i, text in bannerTexts do
        local bx = -FIELD_L/2 + (i-1) * (FIELD_L / (#bannerTexts - 1))
        local banner = part(decoFolder, "Banner_"..i,
            Vector3.new(8, 3, 0.2),
            CFrame.new(bx, FIELD_Y + 22, -FIELD_W/2 - 10),
            "Dark green", Enum.Material.Fabric)
        label(banner, text, Color3.fromRGB(255, 255, 255), Enum.NormalId.Back)
        label(banner, text, Color3.fromRGB(255, 255, 255), Enum.NormalId.Front)
    end

    -- Bolas decorativas gigantes espalhadas
    local ballPositions = {
        Vector3.new(30, FIELD_Y + 4, 45),
        Vector3.new(-40, FIELD_Y + 3, -42),
        Vector3.new(60, FIELD_Y + 5, 20),
        Vector3.new(-20, FIELD_Y + 3, 46),
    }
    for i, pos in ballPositions do
        local b = part(decoFolder, "GiantBall_"..i,
            Vector3.new(6, 6, 6),
            CFrame.new(pos),
            "Institutional white", Enum.Material.SmoothPlastic)
        b.Shape = Enum.PartType.Ball

        -- Pentagono preto decorativo
        local d = Instance.new("Decal")
        d.Color3 = Color3.fromRGB(20, 20, 20)
        d.Face = Enum.NormalId.Front
        d.Parent = b
    end

    -- Trofeu Porco Dourado no centro (como na imagem do jogo)
    local trophy = part(decoFolder, "PorcoDouradoBase",
        Vector3.new(4, 2, 4),
        CFrame.new(0, FIELD_Y + 1, FIELD_W/2 + 8),
        "Gold", Enum.Material.Glass)

    local porcoBody = part(decoFolder, "PorcoDourado",
        Vector3.new(6, 5, 5),
        CFrame.new(0, FIELD_Y + 5, FIELD_W/2 + 8),
        "Gold", Enum.Material.Glass)

    local porcoHead = part(decoFolder, "PorcoHead",
        Vector3.new(3.5, 3.5, 3.5),
        CFrame.new(0, FIELD_Y + 8.5, FIELD_W/2 + 8),
        "Gold", Enum.Material.Glass)
    porcoHead.Shape = Enum.PartType.Ball

    -- Coroa do Porco Dourado
    local crown = part(decoFolder, "PorcoCrown",
        Vector3.new(3, 1.5, 3),
        CFrame.new(0, FIELD_Y + 10.5, FIELD_W/2 + 8),
        "Gold", Enum.Material.Neon)

    -- Brilho do Porco Dourado
    local porcoLight = Instance.new("PointLight")
    porcoLight.Range = 40
    porcoLight.Brightness = 3
    porcoLight.Color = Color3.fromRGB(255, 215, 0)
    porcoLight.Parent = porcoBody

    -- Particulas de moedas ao redor do Porco Dourado
    local coinParticles = Instance.new("ParticleEmitter")
    coinParticles.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
    coinParticles.Size = NumberSequence.new(0.8)
    coinParticles.Lifetime = NumberRange.new(2, 4)
    coinParticles.Rate = 8
    coinParticles.Speed = NumberRange.new(3, 8)
    coinParticles.SpreadAngle = Vector2.new(180, 180)
    coinParticles.LightEmission = 0.8
    coinParticles.Parent = porcoBody

    billboard(porcoHead, "PORCO DOURADO REI", Color3.fromRGB(255, 215, 0), Vector3.new(0, 4, 0))
end

-- ============================================================
-- ARCO DE ENTRADA "ALLIANZ BRAINROT ARENA"
-- ============================================================
local function buildEntranceArch(parent)
    local archFolder = Instance.new("Folder")
    archFolder.Name = "EntranceArch"
    archFolder.Parent = parent

    local archZ = -FIELD_W/2 - 25
    local archW = 60
    local archH = 35
    local pillarW = 4

    -- Pilar esquerdo (verde Palmeiras)
    local pillarL = part(archFolder, "PillarL",
        Vector3.new(pillarW, archH, pillarW),
        CFrame.new(-archW/2, FIELD_Y + archH/2, archZ),
        "Dark green", Enum.Material.Concrete)

    -- Pilar direito
    local pillarR = part(archFolder, "PillarR",
        Vector3.new(pillarW, archH, pillarW),
        CFrame.new(archW/2, FIELD_Y + archH/2, archZ),
        "Dark green", Enum.Material.Concrete)

    -- Travessa superior (arco)
    local topBar = part(archFolder, "TopBar",
        Vector3.new(archW + pillarW, 6, pillarW + 2),
        CFrame.new(0, FIELD_Y + archH + 3, archZ),
        "Dark green", Enum.Material.Concrete)

    -- Letreiro principal "ALLIANZ BRAINROT ARENA"
    local signMain = part(archFolder, "SignMain",
        Vector3.new(archW - 4, 8, 0.5),
        CFrame.new(0, FIELD_Y + archH + 10, archZ),
        "Really black", Enum.Material.Glass)
    label(signMain, "ALLIANZ BRAINROT ARENA", Color3.fromRGB(255, 215, 0), Enum.NormalId.Front)
    label(signMain, "ALLIANZ BRAINROT ARENA", Color3.fromRGB(255, 215, 0), Enum.NormalId.Back)

    -- Letreiro neon por tras
    local signGlow = part(archFolder, "SignGlow",
        Vector3.new(archW - 2, 9, 0.3),
        CFrame.new(0, FIELD_Y + archH + 10, archZ - 0.5),
        "Bright green", Enum.Material.Neon)
    signGlow.Transparency = 0.4

    -- Luzes no arco
    for _, xOff in { -archW/4, 0, archW/4 } do
        local archLight = part(archFolder, "ArchLight",
            Vector3.new(2, 1, 2),
            CFrame.new(xOff, FIELD_Y + archH + 0.5, archZ),
            "Institutional white", Enum.Material.Neon)
        local pl = Instance.new("PointLight")
        pl.Range = 30
        pl.Brightness = 2
        pl.Color = Color3.fromRGB(0, 200, 50)
        pl.Parent = archLight
    end

    -- Detalhes dourados nos pilares
    for _, pillar in { pillarL, pillarR } do
        local goldBand = part(archFolder, "GoldBand",
            Vector3.new(pillarW + 0.5, 2, pillarW + 0.5),
            CFrame.new(pillar.Position.X, FIELD_Y + archH - 1, archZ),
            "Gold", Enum.Material.Glass)
        local goldBase = part(archFolder, "GoldBase",
            Vector3.new(pillarW + 1, 2, pillarW + 1),
            CFrame.new(pillar.Position.X, FIELD_Y + 1, archZ),
            "Gold", Enum.Material.Glass)
    end

    -- Escudo do Palmeiras simplificado (circulo verde com P branco)
    local shield = part(archFolder, "PalmeirasShield",
        Vector3.new(6, 6, 0.5),
        CFrame.new(0, FIELD_Y + archH + 19, archZ),
        "Dark green", Enum.Material.Glass)
    label(shield, "P", Color3.fromRGB(255, 255, 255), Enum.NormalId.Front)
    label(shield, "P", Color3.fromRGB(255, 255, 255), Enum.NormalId.Back)

    -- Estrelas douradas (titulos)
    for i = -2, 2 do
        local star = part(archFolder, "Star_"..i,
            Vector3.new(1.2, 1.2, 0.3),
            CFrame.new(i * 3, FIELD_Y + archH + 26, archZ),
            "Gold", Enum.Material.Neon)
    end
end

-- ============================================================
-- CONSTRUCAO PRINCIPAL
-- ============================================================
local function buildStadium()
    print("[StadiumBuilder] Construindo Allianz Brainrot Arena...")

    cleanup()

    -- Folder principal
    local stadium = Instance.new("Folder")
    stadium.Name = "Stadium"
    stadium.Parent = workspace

    -- Remove o Baseplate default se existir
    local baseplate = workspace:FindFirstChild("Baseplate")
    if baseplate then baseplate:Destroy() end

    -- Terreno base (chao ao redor do estadio — verde Palmeiras)
    local ground = part(stadium, "Ground",
        Vector3.new(500, 1, 500),
        CFrame.new(0, FIELD_Y - 0.5, 0),
        "Dark green", Enum.Material.Grass)

    -- Constroi tudo
    buildField(stadium)
    buildStands(stadium)
    createSpawnPoints(stadium)
    buildShop(stadium)
    buildMinigameZones(stadium)
    buildNPCs(stadium)
    buildDecorations(stadium)
    buildEntranceArch(stadium)

    -- Iluminacao — noturna com refletores (estilo jogo noturno)
    game.Lighting.Ambient         = Color3.fromRGB(30, 50, 30)
    game.Lighting.OutdoorAmbient  = Color3.fromRGB(40, 70, 40)
    game.Lighting.Brightness      = 1.5
    game.Lighting.GlobalShadows   = true
    game.Lighting.ClockTime       = 20.5 -- noite com refletores

    -- Verde atmosferico Palmeiras
    local atmosphere = game.Lighting:FindFirstChildOfClass("Atmosphere")
    if not atmosphere then
        atmosphere = Instance.new("Atmosphere")
        atmosphere.Parent = game.Lighting
    end
    atmosphere.Density = 0.15
    atmosphere.Glare = 0.3
    atmosphere.Haze = 2
    atmosphere.Color = Color3.fromRGB(20, 60, 20)

    -- Bloom dourado para efeito de moedas brilhantes
    local bloom = game.Lighting:FindFirstChildOfClass("BloomEffect")
    if not bloom then
        bloom = Instance.new("BloomEffect")
        bloom.Parent = game.Lighting
    end
    bloom.Intensity = 0.5
    bloom.Threshold = 0.8
    bloom.Size = 24

    print("[StadiumBuilder] Allianz Brainrot Arena construida com sucesso!")
end

buildStadium()
