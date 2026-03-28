-- FootballSystem.server.lua
-- ⚽ Sistema de chute de bola — combate principal com temática de futebol
-- Cada jogador recebe uma "Chuteira Brainrot" e chuta bolas para matar mobs

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local MobData    = require(ReplicatedStorage.Shared.MobData)

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local FB = GameConfig.FOOTBALL

-- ============================================================
-- Cooldown por jogador
-- ============================================================
local lastKick = {} -- [player] = tick()

-- ============================================================
-- Cria a ferramenta "Chuteira Brainrot" para o jogador
-- ============================================================
local function createBootTool()
    local tool = Instance.new("Tool")
    tool.Name = "Chuteira Palmeiras ⚽"
    tool.ToolTip = "Chute para destruir brainrots! Segure para carregar."
    tool.RequiresHandle = true
    tool.CanBeDropped = false

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 0.4, 1.4)
    handle.BrickColor = BrickColor.new("Bright green")
    handle.Material = Enum.Material.SmoothPlastic
    handle.CanCollide = false
    handle.Parent = tool

    -- Formato de chuteira (mesh simples)
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.Brick
    mesh.Scale = Vector3.new(1, 0.6, 1.5)
    mesh.Parent = handle

    return tool
end

-- ============================================================
-- Cria a bola de futebol (Part esférica)
-- ============================================================
local function createBall(origin, direction, charge, player)
    local speed = FB.BALL_SPEED + (FB.BALL_MAX_SPEED - FB.BALL_SPEED) * charge
    local damage = FB.BALL_BASE_DAMAGE + (FB.BALL_MAX_DAMAGE - FB.BALL_BASE_DAMAGE) * charge

    local ball = Instance.new("Part")
    ball.Name = "FootballBall_" .. player.Name
    ball.Shape = Enum.PartType.Ball
    ball.Size = Vector3.new(FB.BALL_SIZE, FB.BALL_SIZE, FB.BALL_SIZE)
    ball.BrickColor = BrickColor.new("Institutional white")
    ball.Material = Enum.Material.SmoothPlastic
    ball.CFrame = CFrame.new(origin)
    ball.CanCollide = true
    ball.Anchored = false

    -- Visual: pentágonos pretos (decal simula textura de bola)
    local decal = Instance.new("Decal")
    decal.Color3 = Color3.fromRGB(30, 30, 30)
    decal.Face = Enum.NormalId.Front
    decal.Parent = ball

    -- Carga visual: bola fica amarela/vermelha com carga alta
    if charge > 0.7 then
        ball.BrickColor = BrickColor.new("Bright orange")
        -- Efeito de fogo visual
        local fire = Instance.new("Fire")
        fire.Size = 3
        fire.Heat = 5
        fire.Color = Color3.fromRGB(255, 150, 0)
        fire.Parent = ball
    elseif charge > 0.4 then
        ball.BrickColor = BrickColor.new("Bright yellow")
    end

    -- Física: velocidade na direção do chute com leve arco
    local velocity = Instance.new("BodyVelocity")
    velocity.Velocity = direction.Unit * speed + Vector3.new(0, speed * 0.08, 0)
    velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    velocity.P = 5000
    velocity.Parent = ball

    -- Remover BodyVelocity após 0.3s para permitir gravidade/ricochete
    task.delay(0.3, function()
        if velocity.Parent then
            velocity:Destroy()
        end
    end)

    -- Elasticidade e fricção para quicar
    local props = Instance.new("CustomPhysicalProperties")
    ball.CustomPhysicalProperties = PhysicalProperties.new(
        0.7,   -- density
        0.3,   -- friction
        0.85,  -- elasticity
        1,     -- frictionWeight
        1      -- elasticityWeight
    )

    -- Atributos para identificação
    ball:SetAttribute("Damage", damage)
    ball:SetAttribute("Charge", charge)
    ball:SetAttribute("KickerUserId", player.UserId)
    ball:SetAttribute("HitCount", 0)
    ball:SetAttribute("MaxBounces", FB.BALL_BOUNCE_COUNT)

    ball.Parent = workspace

    -- Auto-destruir após BALL_LIFETIME
    Debris:AddItem(ball, FB.BALL_LIFETIME)

    return ball, damage
end

-- ============================================================
-- Detecta colisão da bola com mobs
-- ============================================================
local function setupBallCollision(ball, player)
    local alreadyHit = {} -- evita dano duplo no mesmo mob

    ball.Touched:Connect(function(hit)
        local model = hit.Parent
        if not model then return end

        -- Não acertar o próprio jogador
        if Players:GetPlayerFromCharacter(model) then return end
        if Players:GetPlayerFromCharacter(hit.Parent and hit.Parent.Parent) then return end

        local humanoid = model:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return end
        if alreadyHit[model] then return end
        alreadyHit[model] = true

        local damage = ball:GetAttribute("Damage") or FB.BALL_BASE_DAMAGE
        local charge = ball:GetAttribute("Charge") or 0

        -- Aplica multiplicador de rebirth ao dano
        local profile = player:FindFirstChild("PlayerProfile")
        local dmgMult = 1
        if profile and profile:FindFirstChild("DamageMultiplier") then
            dmgMult = profile.DamageMultiplier.Value
        end
        damage = math.floor(damage * dmgMult)

        -- Aplica dano
        humanoid:TakeDamage(damage)

        -- Feedback visual no mob
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = ball.AssemblyLinearVelocity.Unit * 30 + Vector3.new(0, 20, 0)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.P = 3000
        bv.Parent = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or hit
        Debris:AddItem(bv, 0.25)

        -- Notifica o cliente
        if Remotes:FindFirstChild("BallHitMob") then
            Remotes.BallHitMob:FireClient(player, model.Name, damage)
        end

        -- Se morreu, o CombatService cuida do reward
        if humanoid.Health <= 0 then
            -- Dispara o evento de kill via DealDamage
            local mobName = model.Name
            local mobInfo = MobData.get(mobName)
            local baseReward = mobInfo and mobInfo.coinReward or GameConfig.COINS_PER_KILL or 10

            -- Coin multiplier do player
            local profile = player:FindFirstChild("PlayerProfile")
            local mult = 1
            if profile and profile:FindFirstChild("CoinMultiplier") then
                mult = profile.CoinMultiplier.Value
            end

            local reward = math.floor(baseReward * mult)

            -- Adiciona kills/coins
            local ls = player:FindFirstChild("leaderstats")
            if ls then
                if ls:FindFirstChild("Kills") then ls.Kills.Value += 1 end
                if ls:FindFirstChild("Coins") then ls.Coins.Value += reward end
            end

            -- Notifica kill
            if Remotes:FindFirstChild("MobKilled") then
                Remotes.MobKilled:FireClient(player, mobName, reward)
            end

            -- Registra no Indice Brainrot
            local indexBindable = ReplicatedStorage:FindFirstChild("IndexMobKill")
            if indexBindable then
                indexBindable:Fire(player, mobName)
            end
        end

        -- Bola com carga alta faz "efeito golpe" (camera shake via BallHitMob)
        -- Incrementa hit count
        local hits = ball:GetAttribute("HitCount") or 0
        ball:SetAttribute("HitCount", hits + 1)

        -- Bola some após atingir um mob (a menos que tenha bounce restante)
        if hits + 1 >= (ball:GetAttribute("MaxBounces") or 1) then
            ball:Destroy()
        end
    end)
end

-- ============================================================
-- Handler: jogador chuta bola
-- ============================================================
local function onKickBall(player, direction, charge)
    -- Validação
    if not player or not player.Character then return end
    if typeof(direction) ~= "Vector3" then return end
    if typeof(charge) ~= "number" then return end

    charge = math.clamp(charge, 0, 1)

    -- Cooldown
    local now = tick()
    local lastTime = lastKick[player] or 0
    local cooldown = FB.KICK_COOLDOWN

    -- Verifica se tem boost de chuteira turbo
    local profile = player:FindFirstChild("PlayerProfile")
    if profile and profile:FindFirstChild("TurboKick") then
        cooldown = cooldown / 2
    end

    if now - lastTime < cooldown then return end
    lastKick[player] = now

    -- Posição de spawn da bola (na frente do personagem)
    local character = player.Character
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local spawnPos = rootPart.Position + direction.Unit * 3 + Vector3.new(0, 1, 0)

    -- Cria e lança a bola
    local ball = createBall(spawnPos, direction, charge, player)
    setupBallCollision(ball, player)

    -- SFX: som de chute
    local kickSound = Instance.new("Sound")
    kickSound.SoundId = "rbxassetid://5153734236" -- som de chute
    kickSound.Volume = 0.5
    kickSound.Parent = rootPart
    kickSound:Play()
    Debris:AddItem(kickSound, 2)
end

-- ============================================================
-- Dar ferramenta ao jogador quando spawna
-- ============================================================
local function onCharacterAdded(player, character)
    task.wait(0.5) -- espera o personagem carregar

    -- Verifica se já tem a chuteira
    local backpack = player:FindFirstChild("Backpack")
    if not backpack then return end

    local hasBoot = backpack:FindFirstChild("Chuteira Brainrot ⚽")
        or character:FindFirstChild("Chuteira Brainrot ⚽")
    if hasBoot then return end

    local tool = createBootTool()
    tool.Parent = backpack
end

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function(character)
        onCharacterAdded(player, character)
    end)
    if player.Character then
        onCharacterAdded(player, player.Character)
    end
end

local function onPlayerRemoving(player)
    lastKick[player] = nil
end

-- ============================================================
-- Conecta eventos
-- ============================================================
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Jogadores que já entraram antes do script rodar
for _, player in Players:GetPlayers() do
    task.spawn(function() onPlayerAdded(player) end)
end

-- Remote: jogador quer chutar bola
Remotes:WaitForChild("KickBall").OnServerEvent:Connect(onKickBall)

print("[FootballSystem] ⚽ Sistema de futebol ativado!")
