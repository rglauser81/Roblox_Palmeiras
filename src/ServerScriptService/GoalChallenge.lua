-- GoalChallenge.lua
-- ⚽ Mini-game de gol durante o intermission
-- Goleiro se move, jogadores chutam bolas no gol para ganhar coins

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local FB = GameConfig.FOOTBALL

local GoalChallenge = {}

-- Estado
local active = false
local keeperModel = nil
local keeperConnection = nil
local goalConnections = {}
local playerGoals = {}  -- [player] = { goals = 0, combo = 0, coins = 0 }

-- ============================================================
-- Cria o goleiro (um Part que se move de um lado pro outro)
-- ============================================================
local function createKeeper(goalX, baseY, round)
    local GOAL_W = 12
    local GOAL_H = 6
    local fieldY = baseY + 4 / 2 + 0.06

    local keeper = Instance.new("Model")
    keeper.Name = "Goalkeeper"

    -- Corpo do goleiro
    local torso = Instance.new("Part")
    torso.Name = "HumanoidRootPart"
    torso.Size = Vector3.new(2, 4, 2)
    torso.CFrame = CFrame.new(goalX, fieldY + 2, 0)
    torso.Anchored = true
    torso.CanCollide = true
    torso.BrickColor = BrickColor.new("Bright orange")
    torso.Material = Enum.Material.SmoothPlastic
    torso.Parent = keeper

    -- Cabeça
    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(1.6, 1.6, 1.6)
    head.Shape = Enum.PartType.Ball
    head.CFrame = CFrame.new(goalX, fieldY + 4.8, 0)
    head.Anchored = true
    head.CanCollide = true
    head.BrickColor = BrickColor.new("Bright yellow")
    head.Material = Enum.Material.SmoothPlastic
    head.Parent = keeper

    -- Luvas (mãos)
    local leftGlove = Instance.new("Part")
    leftGlove.Name = "LeftGlove"
    leftGlove.Size = Vector3.new(1, 1, 1)
    leftGlove.CFrame = CFrame.new(goalX, fieldY + 3, -1.8)
    leftGlove.Anchored = true
    leftGlove.CanCollide = true
    leftGlove.BrickColor = BrickColor.new("Bright green")
    leftGlove.Material = Enum.Material.SmoothPlastic
    leftGlove.Parent = keeper

    local rightGlove = Instance.new("Part")
    rightGlove.Name = "RightGlove"
    rightGlove.Size = Vector3.new(1, 1, 1)
    rightGlove.CFrame = CFrame.new(goalX, fieldY + 3, 1.8)
    rightGlove.Anchored = true
    rightGlove.CanCollide = true
    rightGlove.BrickColor = BrickColor.new("Bright green")
    rightGlove.Material = Enum.Material.SmoothPlastic
    rightGlove.Parent = keeper

    -- Nametag
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.Adornee = head
    billboard.Parent = head

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "🧤 GOLEIRO BRAINROT"
    nameLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 16
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.Parent = billboard

    keeper.PrimaryPart = torso
    keeper.Parent = workspace

    keeperModel = keeper

    -- Animação: movimentação lateral
    local keeperSpeed = FB.KEEPER_BASE_SPEED + (round - 1) * FB.KEEPER_SPEED_SCALE
    local maxZ = GOAL_W / 2 - 2  -- range de movimento
    local direction = 1

    keeperConnection = RunService.Heartbeat:Connect(function(dt)
        if not active then return end
        if not torso.Parent then return end

        local currentZ = torso.Position.Z
        local newZ = currentZ + direction * keeperSpeed * dt

        -- Inverte direção nos limites
        if newZ >= maxZ then
            newZ = maxZ
            direction = -1
        elseif newZ <= -maxZ then
            newZ = -maxZ
            direction = 1
        end

        local basePos = torso.Position
        torso.CFrame = CFrame.new(basePos.X, basePos.Y, newZ)
        head.CFrame = CFrame.new(basePos.X, head.Position.Y, newZ)
        leftGlove.CFrame = CFrame.new(basePos.X, leftGlove.Position.Y, newZ - 1.8)
        rightGlove.CFrame = CFrame.new(basePos.X, rightGlove.Position.Y, newZ + 1.8)
    end)

    return keeper
end

-- ============================================================
-- Detecta gol: bola toca no GoalTrigger
-- ============================================================
local function setupGoalDetection()
    local pitch = workspace:FindFirstChild("FootballPitch")
    if not pitch then
        warn("[GoalChallenge] FootballPitch não encontrado!")
        return
    end

    for _, child in pitch:GetChildren() do
        if child.Name:match("GoalTrigger") then
            local conn = child.Touched:Connect(function(hit)
                if not active then return end
                if not hit.Name:match("FootballBall_") then return end

                -- Identificar quem chutou
                local kickerUserId = hit:GetAttribute("KickerUserId")
                if not kickerUserId then return end

                local player = nil
                for _, p in Players:GetPlayers() do
                    if p.UserId == kickerUserId then
                        player = p
                        break
                    end
                end

                if not player then return end

                -- Verifica se esta bola já marcou gol
                if hit:GetAttribute("GoalScored") then return end
                hit:SetAttribute("GoalScored", true)

                -- Registra gol
                if not playerGoals[player] then
                    playerGoals[player] = { goals = 0, combo = 0, coins = 0 }
                end

                local data = playerGoals[player]
                data.goals += 1
                data.combo += 1

                -- Calcula coins com combo
                local comboMult = 1 + (data.combo - 1) * (FB.GOAL_COMBO_MULT - 1)
                local coins = math.floor(FB.GOAL_COINS_BASE * comboMult)
                data.coins += coins

                -- Adiciona coins ao jogador
                local ls = player:FindFirstChild("leaderstats")
                if ls and ls:FindFirstChild("Coins") then
                    ls.Coins.Value += coins
                end

                -- Notifica o jogador
                local Remotes = ReplicatedStorage:WaitForChild("Remotes")
                if Remotes:FindFirstChild("GoalScored") then
                    Remotes.GoalScored:FireClient(player, coins, data.combo)
                end

                -- Broadcast para todos
                if Remotes:FindFirstChild("GlobalAnnounce") then
                    Remotes.GlobalAnnounce:FireAllClients(
                        "⚽ " .. player.DisplayName .. " marcou um gol! (x" .. data.combo .. ")",
                        Color3.fromRGB(100, 255, 100)
                    )
                end

                -- Destrói a bola
                hit:Destroy()
            end)
            table.insert(goalConnections, conn)
        end
    end
end

-- ============================================================
-- API Pública
-- ============================================================

function GoalChallenge.start(round, duration)
    if active then return end
    active = true
    playerGoals = {}
    duration = duration or FB.GOAL_CHALLENGE_DURATION

    local Remotes = ReplicatedStorage:WaitForChild("Remotes")

    print("[GoalChallenge] ⚽ Desafio de Gol iniciado! Rodada:", round)

    -- Cria goleiro no gol Oeste (-50)
    local baseY = GameConfig.FLOORS[1].spawnHeight
    createKeeper(-49, baseY, round)

    -- Configura detecção de gol
    setupGoalDetection()

    -- Notifica todos os jogadores
    if Remotes:FindFirstChild("GoalChallengeStart") then
        Remotes.GoalChallengeStart:FireAllClients(duration)
    end

    if Remotes:FindFirstChild("GlobalAnnounce") then
        Remotes.GlobalAnnounce:FireAllClients(
            "⚽ DESAFIO DE GOL! Chute bolas no gol por " .. duration .. "s!",
            Color3.fromRGB(255, 215, 0)
        )
    end

    -- Espera a duração
    task.wait(duration)

    -- Encerra
    GoalChallenge.stop()
end

function GoalChallenge.stop()
    if not active then return end
    active = false

    local Remotes = ReplicatedStorage:WaitForChild("Remotes")

    -- Limpa goleiro
    if keeperConnection then
        keeperConnection:Disconnect()
        keeperConnection = nil
    end
    if keeperModel and keeperModel.Parent then
        keeperModel:Destroy()
    end
    keeperModel = nil

    -- Limpa conexões de gol
    for _, conn in goalConnections do
        conn:Disconnect()
    end
    goalConnections = {}

    -- Notifica resultados finais
    for player, data in playerGoals do
        if player.Parent then -- ainda está no jogo
            if Remotes:FindFirstChild("GoalChallengeEnd") then
                Remotes.GoalChallengeEnd:FireClient(player, data.goals, data.coins)
            end
        end
    end

    -- Jogadores que não marcaram gol
    for _, player in Players:GetPlayers() do
        if not playerGoals[player] then
            if Remotes:FindFirstChild("GoalChallengeEnd") then
                Remotes.GoalChallengeEnd:FireClient(player, 0, 0)
            end
        end
    end

    print("[GoalChallenge] ⚽ Desafio encerrado!")
    playerGoals = {}
end

function GoalChallenge.isActive()
    return active
end

return GoalChallenge
