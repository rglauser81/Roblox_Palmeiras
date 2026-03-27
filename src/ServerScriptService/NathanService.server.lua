-- NathanService.server.lua
-- 👑 Poderes, aura, tag e comandos exclusivos do criador Nathan

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChatService = game:GetService("Chat")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

-- ============================================================
-- Utilitários
-- ============================================================

local function isNathan(player)
    if GameConfig.NATHAN_USER_ID == 0 then
        -- Modo teste: primeiro jogador no servidor
        return #Players:GetPlayers() == 1
    end
    return player.UserId == GameConfig.NATHAN_USER_ID
end

-- ============================================================
-- Aura dourada com partículas + PointLight
-- ============================================================

local function applyNathanAura(character)
    local root = character:WaitForChild("HumanoidRootPart", 5)
    if not root then return end

    -- Remove aura anterior se existir
    local old = root:FindFirstChild("NathanAura")
    if old then old:Destroy() end

    -- Attachment base
    local attachment = Instance.new("Attachment")
    attachment.Name = "NathanAura"
    attachment.Parent = root

    -- PointLight dourada
    local light = Instance.new("PointLight")
    light.Color      = GameConfig.NATHAN_AURA_COLOR
    light.Range      = GameConfig.NATHAN_LIGHT_RANGE
    light.Brightness = GameConfig.NATHAN_LIGHT_BRIGHT
    light.Parent = root

    -- Partículas de ouro
    local particles = Instance.new("ParticleEmitter")
    particles.Color       = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 140, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 200)),
    })
    particles.LightEmission  = 1
    particles.LightInfluence = 0
    particles.Size            = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(0.5, 0.5),
        NumberSequenceKeypoint.new(1, 0),
    })
    particles.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.8, 0.4),
        NumberSequenceKeypoint.new(1, 1),
    })
    particles.Speed       = NumberRange.new(2, 6)
    particles.Rate        = 40
    particles.Lifetime    = NumberRange.new(0.8, 1.5)
    particles.RotSpeed    = NumberRange.new(-45, 45)
    particles.SpreadAngle = Vector2.new(180, 180)
    particles.Parent = attachment

    -- Trilha de ouro
    local trail = Instance.new("Trail")
    local a0 = Instance.new("Attachment") a0.Position = Vector3.new(0, 1, 0)  a0.Parent = root
    local a1 = Instance.new("Attachment") a1.Position = Vector3.new(0, -1, 0) a1.Parent = root
    trail.Attachment0   = a0
    trail.Attachment1   = a1
    trail.Color         = ColorSequence.new(GameConfig.NATHAN_AURA_COLOR, Color3.fromRGB(255, 255, 255))
    trail.Transparency  = NumberSequence.new(0.2, 1)
    trail.Lifetime      = 0.4
    trail.LightEmission = 0.8
    trail.Parent = root
end

-- ============================================================
-- Tag flutuante "⚡ Nathan — Criador ⚡"
-- ============================================================

local function applyNathanTag(character, player)
    local head = character:WaitForChild("Head", 5)
    if not head then return end

    -- BillboardGui sobre a cabeça
    local billboard = Instance.new("BillboardGui")
    billboard.Name          = "NathanTag"
    billboard.Size          = UDim2.new(0, 260, 0, 44)
    billboard.StudsOffset   = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop   = false
    billboard.MaxDistance   = 60
    billboard.Parent        = head

    local label = Instance.new("TextLabel")
    label.Size              = UDim2.new(1, 0, 1, 0)
    label.BackgroundColor3  = Color3.fromRGB(20, 20, 20)
    label.BackgroundTransparency = 0.3
    label.TextColor3        = Color3.fromRGB(255, 200, 0)
    label.Text              = "⚡ " .. GameConfig.NATHAN_DISPLAY_NAME .. " — Criador ⚡"
    label.Font              = Enum.Font.GothamBold
    label.TextSize          = 15
    label.TextStrokeColor3  = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0.4
    label.Parent            = billboard

    -- Arredondado
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent       = label
end

-- ============================================================
-- Poderes do Nathan: velocidade 1.5x + todas as áreas
-- ============================================================

local function applyNathanPerks(player, character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if humanoid then
        humanoid.WalkSpeed = 24   -- padrão 16 × 1.5
        humanoid.JumpPower = 60   -- padrão 50
    end

    -- Marca no perfil do jogador para o servidor desbloquear lojas
    local profile = player:FindFirstChild("PlayerProfile")
    if profile then
        local isCreator = profile:FindFirstChild("IsCreator")
        if not isCreator then
            local v = Instance.new("BoolValue")
            v.Name   = "IsCreator"
            v.Value  = true
            v.Parent = profile
        end
    end
end

-- ============================================================
-- Comandos de chat do Nathan
-- ============================================================

local function handleNathanCommand(player, message)
    if not isNathan(player) then return end

    local cmd = message:lower():match("^(%S+)")

    -- /chuva — chuva de coins para todos
    if cmd == "/chuva" then
        for _, p in Players:GetPlayers() do
            local ls = p:FindFirstChild("leaderstats")
            if ls and ls:FindFirstChild("Coins") then
                ls.Coins.Value += 500
            end
        end
        game:GetService("Chat"):Chat(
            workspace:FindFirstChildOfClass("Part") or workspace.Terrain,
            "☔ [Nathan] Chuva de coins! Todos ganharam +500 coins!", Enum.ChatColor.Gold
        )
        return true
    end

    -- /divino — mata todos os mobs
    if cmd == "/divino" then
        for _, obj in workspace:GetChildren() do
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
                hum.Health = 0
            end
        end
        return true
    end

    -- /boost — velocidade global por 60s
    if cmd == "/boost" then
        for _, p in Players:GetPlayers() do
            local char = p.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed += 10
                    task.delay(60, function()
                        if hum and hum.Parent then
                            hum.WalkSpeed -= 10
                        end
                    end)
                end
            end
        end
        return true
    end

    -- /evento — anuncia evento especial (extende para MobSpawner no futuro)
    if cmd == "/evento" then
        local Remotes = ReplicatedStorage:WaitForChild("Remotes")
        if Remotes:FindFirstChild("GlobalAnnounce") then
            Remotes.GlobalAnnounce:FireAllClients("🎉 EVENTO ESPECIAL ativado pelo Nathan!", Color3.fromRGB(255, 80, 200))
        end
        return true
    end

    return false
end

-- ============================================================
-- Setup quando jogador entra
-- ============================================================

local function onCharacterAdded(player, character)
    if not isNathan(player) then return end
    character:WaitForChild("HumanoidRootPart", 10)

    applyNathanAura(character)
    applyNathanTag(character, player)
    applyNathanPerks(player, character)

    -- Anúncio global de entrada
    task.delay(2, function()
        local Remotes = ReplicatedStorage:WaitForChild("Remotes")
        if Remotes:FindFirstChild("GlobalAnnounce") then
            Remotes.GlobalAnnounce:FireAllClients(
                "👑 " .. GameConfig.NATHAN_DISPLAY_NAME .. " entrou no servidor!",
                GameConfig.NATHAN_AURA_COLOR
            )
        end
    end)
end

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function(character)
        onCharacterAdded(player, character)
    end)

    -- Chat listener
    player.Chatted:Connect(function(msg)
        handleNathanCommand(player, msg)
    end)

    -- Se o personagem já existe (re-join rápido)
    if player.Character then
        onCharacterAdded(player, player.Character)
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, p in Players:GetPlayers() do onPlayerAdded(p) end
