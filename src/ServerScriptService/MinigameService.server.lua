-- MinigameService.server.lua
-- Gerencia os 6 mini-games interativos espalhados pelo estadio
-- Cada mini-game tem trigger, timer, logica propria e recompensa

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local FB = GameConfig.FOOTBALL

-- Estado ativo por jogador
local activePlayers = {} -- [userId] = { mgId = string, startTime = tick(), ... }

-- Debounce: evita duplo-trigger
local triggerDebounce = {} -- [userId] = tick()

-- ============================================================
-- Utilidades
-- ============================================================

local function getMinigameConfig(mgId)
    for _, mg in GameConfig.MINIGAMES do
        if mg.id == mgId then return mg end
    end
    return nil
end

local function rewardPlayer(player, coins)
    local ls = player:FindFirstChild("leaderstats")
    if ls and ls:FindFirstChild("Coins") then
        ls.Coins.Value += coins
    end
end

local function makePart(parent, name, size, cf, color, mat)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.CFrame = cf
    p.BrickColor = BrickColor.new(color or "Medium stone grey")
    p.Material = mat or Enum.Material.SmoothPlastic
    p.Anchored = true
    p.Parent = parent
    return p
end

-- ============================================================
-- DRIBBLE COURSE: desviar dos cones moveis por X segundos
-- ============================================================
local function startDribbleCourse(player, mgConfig)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local origin = mgConfig.position
    local folder = Instance.new("Folder")
    folder.Name = "DribbleCourse_"..player.UserId
    folder.Parent = workspace

    -- Cria cones que se movem
    local cones = {}
    for i = 1, 6 do
        local cone = makePart(folder, "Cone_"..i,
            Vector3.new(2, 4, 2),
            CFrame.new(origin.X + math.random(-8, 8), GameConfig.STADIUM.FIELD_Y + 2, origin.Z + math.random(-8, 8)),
            "Neon orange", Enum.Material.Neon)
        table.insert(cones, cone)
    end

    local score = 0
    local startTime = tick()
    local endTime = startTime + mgConfig.duration

    -- Move cones e detecta colisao
    local connections = {}
    for _, cone in cones do
        local dir = Vector3.new(math.random(-1,1)*3, 0, math.random(-1,1)*3)
        local conn
        conn = game:GetService("RunService").Heartbeat:Connect(function(dt)
            if tick() > endTime or not cone.Parent then
                conn:Disconnect()
                return
            end
            cone.CFrame = cone.CFrame + dir * dt
            -- Inverte se sair da area
            local pos = cone.Position
            if math.abs(pos.X - origin.X) > 10 or math.abs(pos.Z - origin.Z) > 10 then
                dir = -dir
            end
        end)
        table.insert(connections, conn)

        cone.Touched:Connect(function(hit)
            if Players:GetPlayerFromCharacter(hit.Parent) == player then
                -- Jogador tocou cone: penalidade (perde 1 ponto)
                score = math.max(0, score - 1)
            end
        end)
    end

    -- Conta sobrevivencia: 1 ponto por segundo sem tocar cone
    task.spawn(function()
        while tick() < endTime and activePlayers[player.UserId] do
            task.wait(1)
            score += 1
        end
    end)

    -- Aguarda fim
    task.delay(mgConfig.duration, function()
        for _, c in connections do c:Disconnect() end
        folder:Destroy()
        activePlayers[player.UserId] = nil

        local reward = math.floor(mgConfig.reward * math.clamp(score / mgConfig.duration, 0.1, 2))
        rewardPlayer(player, reward)
        Remotes.MinigameEnd:FireClient(player, mgConfig.id, reward, score)
    end)
end

-- ============================================================
-- PENALTY SHOOTOUT: chutar bola em gol com goleiro movel
-- ============================================================
local function startPenaltyShootout(player, mgConfig)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local origin = mgConfig.position
    local folder = Instance.new("Folder")
    folder.Name = "Penalty_"..player.UserId
    folder.Parent = workspace

    -- Mini-gol
    local goalW = 10
    local goalH = 5
    local goalX = origin.X + 12
    local goalZ = origin.Z

    makePart(folder, "PostL", Vector3.new(0.5, goalH, 0.5), CFrame.new(goalX, GameConfig.STADIUM.FIELD_Y + goalH/2, goalZ - goalW/2), "White", Enum.Material.Metal)
    makePart(folder, "PostR", Vector3.new(0.5, goalH, 0.5), CFrame.new(goalX, GameConfig.STADIUM.FIELD_Y + goalH/2, goalZ + goalW/2), "White", Enum.Material.Metal)
    makePart(folder, "Bar", Vector3.new(0.5, 0.5, goalW), CFrame.new(goalX, GameConfig.STADIUM.FIELD_Y + goalH, goalZ), "White", Enum.Material.Metal)

    -- Goleiro (parte movel)
    local keeper = makePart(folder, "Keeper",
        Vector3.new(2, 4, 2),
        CFrame.new(goalX - 1, GameConfig.STADIUM.FIELD_Y + 2, goalZ),
        "Bright green")

    -- Trigger de gol
    local goalTrigger = Instance.new("Part")
    goalTrigger.Name = "GoalTrigger"
    goalTrigger.Size = Vector3.new(2, goalH, goalW - 1)
    goalTrigger.CFrame = CFrame.new(goalX, GameConfig.STADIUM.FIELD_Y + goalH/2, goalZ)
    goalTrigger.Transparency = 1
    goalTrigger.CanCollide = false
    goalTrigger.Anchored = true
    goalTrigger.Parent = folder

    local goals = 0
    local startTime = tick()
    local endTime = startTime + mgConfig.duration

    -- Goleiro se move
    local keeperConn
    local keeperDir = 1
    keeperConn = game:GetService("RunService").Heartbeat:Connect(function(dt)
        if tick() > endTime then keeperConn:Disconnect(); return end
        local kz = keeper.Position.Z + keeperDir * 8 * dt
        if math.abs(kz - goalZ) > goalW/2 - 1.5 then keeperDir = -keeperDir end
        keeper.CFrame = CFrame.new(goalX - 1, GameConfig.STADIUM.FIELD_Y + 2, kz)
    end)

    -- Detecta bolas que entram no gol
    goalTrigger.Touched:Connect(function(hit)
        if hit.Name:match("^FootballBall_") then
            local kickerId = hit:GetAttribute("KickerUserId")
            if kickerId == player.UserId then
                goals += 1
                hit:Destroy()
                Remotes.MinigameProgress:FireClient(player, mgConfig.id, goals)
            end
        end
    end)

    task.delay(mgConfig.duration, function()
        keeperConn:Disconnect()
        folder:Destroy()
        activePlayers[player.UserId] = nil

        local reward = mgConfig.reward * goals
        rewardPlayer(player, reward)
        Remotes.MinigameEnd:FireClient(player, mgConfig.id, reward, goals)
    end)
end

-- ============================================================
-- KEEPY UPPY: manter bola no ar clicando (client-driven, server valida)
-- ============================================================
local function startKeepyUppy(player, mgConfig)
    -- Este mini-game e mais client-driven
    -- Server cria a bola e valida o resultado
    local origin = mgConfig.position
    local ball = Instance.new("Part")
    ball.Name = "KeepyBall_"..player.UserId
    ball.Shape = Enum.PartType.Ball
    ball.Size = Vector3.new(2.5, 2.5, 2.5)
    ball.BrickColor = BrickColor.new("Institutional white")
    ball.Material = Enum.Material.SmoothPlastic
    ball.CFrame = CFrame.new(origin.X, GameConfig.STADIUM.FIELD_Y + 5, origin.Z)
    ball.Anchored = false
    ball.Parent = workspace

    ball.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0.2, 0.9, 1, 1)

    ball:SetAttribute("OwnerUserId", player.UserId)
    ball:SetAttribute("MinigameId", mgConfig.id)

    local touches = 0

    ball.Touched:Connect(function(hit)
        local p = Players:GetPlayerFromCharacter(hit.Parent)
        if p and p.UserId == player.UserId then
            touches += 1
            -- Empurra pra cima
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(math.random(-3,3), 20, math.random(-3,3))
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Parent = ball
            Debris:AddItem(bv, 0.15)
            Remotes.MinigameProgress:FireClient(player, mgConfig.id, touches)
        end
    end)

    task.delay(mgConfig.duration, function()
        if ball.Parent then ball:Destroy() end
        activePlayers[player.UserId] = nil

        local reward = math.floor(mgConfig.reward * math.clamp(touches / 10, 0.5, 3))
        rewardPlayer(player, reward)
        Remotes.MinigameEnd:FireClient(player, mgConfig.id, reward, touches)
    end)
end

-- ============================================================
-- TACKLE DODGE: fugir de brainrots que dao carrinho
-- ============================================================
local function startTackleDodge(player, mgConfig)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local origin = mgConfig.position
    local folder = Instance.new("Folder")
    folder.Name = "TackleDodge_"..player.UserId
    folder.Parent = workspace

    local tacklers = {}
    for i = 1, 4 do
        local t = makePart(folder, "Tackler_"..i,
            Vector3.new(2, 2, 4),
            CFrame.new(origin.X + math.random(-10, 10), GameConfig.STADIUM.FIELD_Y + 1, origin.Z + math.random(-10, 10)),
            "Really red", Enum.Material.Neon)
        t:SetAttribute("Speed", 8 + i * 2)
        table.insert(tacklers, t)
    end

    local survived = true
    local hitCount = 0
    local endTime = tick() + mgConfig.duration

    local connections = {}
    for _, tackler in tacklers do
        -- Move toward player
        local c = game:GetService("RunService").Heartbeat:Connect(function(dt)
            if tick() > endTime or not char.Parent then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local dir = (root.Position - tackler.Position).Unit
            dir = Vector3.new(dir.X, 0, dir.Z)
            local spd = tackler:GetAttribute("Speed") or 10
            tackler.CFrame = tackler.CFrame + dir * spd * dt
        end)
        table.insert(connections, c)

        tackler.Touched:Connect(function(hit)
            if Players:GetPlayerFromCharacter(hit.Parent) == player then
                hitCount += 1
                -- Knockback
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    local bv = Instance.new("BodyVelocity")
                    bv.Velocity = (root.Position - tackler.Position).Unit * 30 + Vector3.new(0, 15, 0)
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.Parent = root
                    Debris:AddItem(bv, 0.2)
                end
            end
        end)
    end

    task.delay(mgConfig.duration, function()
        for _, c in connections do c:Disconnect() end
        folder:Destroy()
        activePlayers[player.UserId] = nil

        local dodgeScore = math.max(0, mgConfig.duration * 2 - hitCount * 3)
        local reward = math.floor(mgConfig.reward * math.clamp(dodgeScore / (mgConfig.duration * 2), 0.2, 1))
        rewardPlayer(player, reward)
        Remotes.MinigameEnd:FireClient(player, mgConfig.id, reward, dodgeScore)
    end)
end

-- ============================================================
-- TARGET KICK: acertar alvos com a bola
-- ============================================================
local function startTargetKick(player, mgConfig)
    local origin = mgConfig.position
    local folder = Instance.new("Folder")
    folder.Name = "TargetKick_"..player.UserId
    folder.Parent = workspace

    local targets = {}
    local hits = 0

    -- Spawna alvos em posicoes variadas
    local function spawnTarget()
        local t = makePart(folder, "Target",
            Vector3.new(3, 3, 0.5),
            CFrame.new(
                origin.X + math.random(-8, 8),
                GameConfig.STADIUM.FIELD_Y + math.random(2, 8),
                origin.Z + math.random(-8, 8)
            ),
            "Bright red", Enum.Material.Neon)

        t.Touched:Connect(function(hit)
            if hit.Name:match("^FootballBall_") then
                local kickerId = hit:GetAttribute("KickerUserId")
                if kickerId == player.UserId then
                    hits += 1
                    t:Destroy()
                    Remotes.MinigameProgress:FireClient(player, mgConfig.id, hits)
                    -- Spawna novo alvo
                    task.delay(0.5, function()
                        if activePlayers[player.UserId] then
                            spawnTarget()
                        end
                    end)
                end
            end
        end)

        table.insert(targets, t)
    end

    -- Começa com 3 alvos
    for i = 1, 3 do spawnTarget() end

    task.delay(mgConfig.duration, function()
        folder:Destroy()
        activePlayers[player.UserId] = nil

        local reward = mgConfig.reward * hits
        rewardPlayer(player, reward)
        Remotes.MinigameEnd:FireClient(player, mgConfig.id, reward, hits)
    end)
end

-- ============================================================
-- SPEED DRIBBLE: correr de um lado ao outro com a bola
-- ============================================================
local function startSpeedDribble(player, mgConfig)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local origin = mgConfig.position
    local folder = Instance.new("Folder")
    folder.Name = "SpeedDribble_"..player.UserId
    folder.Parent = workspace

    -- Ponto de partida e chegada
    local startPad = makePart(folder, "StartPad",
        Vector3.new(6, 0.3, 6),
        CFrame.new(origin.X - 15, GameConfig.STADIUM.FIELD_Y + 0.15, origin.Z),
        "Bright green", Enum.Material.Neon)

    local endPad = makePart(folder, "EndPad",
        Vector3.new(6, 0.3, 6),
        CFrame.new(origin.X + 15, GameConfig.STADIUM.FIELD_Y + 0.15, origin.Z),
        "Bright yellow", Enum.Material.Neon)

    -- Obstaculos no caminho
    for i = 1, 5 do
        makePart(folder, "Obstacle_"..i,
            Vector3.new(1, 3, 1),
            CFrame.new(origin.X - 12 + i * 5, GameConfig.STADIUM.FIELD_Y + 1.5, origin.Z + math.random(-4, 4)),
            "Neon orange", Enum.Material.Neon)
    end

    local laps = 0
    local atStart = true

    endPad.Touched:Connect(function(hit)
        if Players:GetPlayerFromCharacter(hit.Parent) == player and atStart then
            laps += 1
            atStart = false
            Remotes.MinigameProgress:FireClient(player, mgConfig.id, laps)
        end
    end)

    startPad.Touched:Connect(function(hit)
        if Players:GetPlayerFromCharacter(hit.Parent) == player and not atStart then
            atStart = true
        end
    end)

    task.delay(mgConfig.duration, function()
        folder:Destroy()
        activePlayers[player.UserId] = nil

        local reward = mgConfig.reward * laps
        rewardPlayer(player, reward)
        Remotes.MinigameEnd:FireClient(player, mgConfig.id, reward, laps)
    end)
end

-- ============================================================
-- Dispatch: inicia o mini-game correto
-- ============================================================
local dispatchers = {
    dribble_course   = startDribbleCourse,
    penalty_shootout = startPenaltyShootout,
    keepy_uppy       = startKeepyUppy,
    tackle_dodge     = startTackleDodge,
    target_kick      = startTargetKick,
    speed_dribble    = startSpeedDribble,
}

local function startMinigame(player, mgId)
    if activePlayers[player.UserId] then
        return -- ja esta em um minigame
    end

    local mgConfig = getMinigameConfig(mgId)
    if not mgConfig then return end

    local fn = dispatchers[mgId]
    if not fn then return end

    activePlayers[player.UserId] = { mgId = mgId, startTime = tick() }
    Remotes.MinigameStart:FireClient(player, mgId, mgConfig.name, mgConfig.description, mgConfig.duration, mgConfig.reward)

    fn(player, mgConfig)
end

-- ============================================================
-- Triggers do StadiumBuilder: detecta jogadores pisando na zona
-- ============================================================
local function setupTriggers()
    local zonesFolder = workspace:WaitForChild("Stadium", 30) and workspace.Stadium:FindFirstChild("MinigameZones")
    if not zonesFolder then
        -- Tenta buscar fora do Stadium
        zonesFolder = workspace:FindFirstChild("MinigameZones")
    end
    if not zonesFolder then
        warn("[MinigameService] MinigameZones nao encontrado")
        return
    end

    for _, child in zonesFolder:GetChildren() do
        if child.Name:match("^MinigameTrigger_") then
            local mgId = child.Name:gsub("MinigameTrigger_", "")
            child.Touched:Connect(function(hit)
                local player = Players:GetPlayerFromCharacter(hit.Parent)
                if not player then return end

                local uid = player.UserId
                local now = tick()
                if triggerDebounce[uid] and now - triggerDebounce[uid] < 3 then return end
                triggerDebounce[uid] = now

                if activePlayers[uid] then return end
                startMinigame(player, mgId)
            end)
        end
    end
end

-- Tambem aceita via Remote (para UI de join)
Remotes:WaitForChild("MinigameJoin").OnServerEvent:Connect(function(player, mgId)
    if typeof(mgId) ~= "string" then return end
    startMinigame(player, mgId)
end)

-- Limpa ao sair
Players.PlayerRemoving:Connect(function(player)
    activePlayers[player.UserId] = nil
    triggerDebounce[player.UserId] = nil
end)

-- Espera o estadio ser construido e conecta triggers
task.spawn(function()
    task.wait(3) -- espera StadiumBuilder
    setupTriggers()
end)

print("[MinigameService] Inicializado com", #GameConfig.MINIGAMES, "minigames!")
