-- =============================================
-- 05_NathanSystem (Script)
-- LOCAL: ServerScriptService > NathanSystem
-- =============================================
-- IMPORTANTE: Troque Config.Nathan.userId pelo UserId
-- real do Nathan no Roblox!
-- Para descobrir: https://www.roblox.com/users/USERID/profile
-- =============================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GameConfig"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local nathanComando = remotes:WaitForChild("NathanComando")
local notificacao = remotes:WaitForChild("Notificacao")

-- TROCAR AQUI pelo UserId do Nathan
local NATHAN_USERID = Config.Nathan.userId -- 0 = desabilitado

local function isNathan(player)
    if NATHAN_USERID == 0 then
        -- Se userId = 0, primeiro jogador a entrar vira "Nathan" (para teste)
        return player == Players:GetPlayers()[1]
    end
    return player.UserId == NATHAN_USERID
end

-- Quando Nathan entra
Players.PlayerAdded:Connect(function(player)
    task.wait(3)
    if not isNathan(player) then return end

    -- Anúncio global
    for _, p in ipairs(Players:GetPlayers()) do
        notificacao:FireClient(p, "👑 O CRIADOR NATHAN ENTROU NO SERVIDOR! 👑", "sucesso")
    end

    -- Esperar character
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")

    -- Velocidade extra
    humanoid.WalkSpeed = 16 * Config.Nathan.velocidadeExtra

    -- Aura dourada ao redor do personagem
    local auraPart = Instance.new("Part")
    auraPart.Name = "AuraNathan"
    auraPart.Size = Vector3.new(8, 10, 8)
    auraPart.Shape = Enum.PartType.Ball
    auraPart.Color = Config.Nathan.corAura
    auraPart.Material = Enum.Material.ForceField
    auraPart.Transparency = 0.7
    auraPart.CanCollide = false
    auraPart.Anchored = false
    auraPart.Parent = char

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = char:WaitForChild("HumanoidRootPart")
    weld.Part1 = auraPart
    weld.Parent = auraPart

    auraPart.CFrame = char.HumanoidRootPart.CFrame

    -- Luz
    local light = Instance.new("PointLight")
    light.Color = Config.Nathan.corAura
    light.Brightness = 3
    light.Range = 30
    light.Parent = auraPart

    -- Partículas divinas
    local particles = Instance.new("ParticleEmitter")
    particles.Rate = 30
    particles.Lifetime = NumberRange.new(1, 2)
    particles.Speed = NumberRange.new(2, 5)
    particles.Color = ColorSequence.new(Config.Nathan.corAura)
    particles.Size = NumberSequence.new(0.5, 0)
    particles.LightEmission = 1
    particles.Parent = char.HumanoidRootPart

    -- Tag overhead
    local bg = Instance.new("BillboardGui")
    bg.Size = UDim2.new(0, 300, 0, 50)
    bg.StudsOffset = Vector3.new(0, 3, 0)
    bg.AlwaysOnTop = true
    bg.Parent = char.Head

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = Config.Nathan.nomeDisplay
    txt.TextColor3 = Color3.fromRGB(255, 215, 0)
    txt.TextScaled = true
    txt.Font = Enum.Font.GothamBold
    txt.TextStrokeColor3 = Color3.new(0, 0, 0)
    txt.TextStrokeTransparency = 0
    txt.Parent = bg

    -- Todas as áreas desbloqueadas
    local modData = ReplicatedStorage:WaitForChild("ModPlayerData")
    local todasAreas = {}
    for _, r in ipairs(Config.Raridades) do
        table.insert(todasAreas, r.nome)
    end
    modData:Fire(player.UserId, "areasDesbloqueadas", todasAreas)
    modData:Fire(player.UserId, "desafiosCompletos", #Config.Raridades)
    modData:Fire(player.UserId, "slotsBase", 50)

    -- Re-aplicar ao respawnar
    player.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        local hum = newChar:WaitForChild("Humanoid")
        hum.WalkSpeed = 16 * Config.Nathan.velocidadeExtra

        local aura2 = auraPart:Clone()
        aura2.Parent = newChar
        local w2 = Instance.new("WeldConstraint")
        w2.Part0 = newChar:WaitForChild("HumanoidRootPart")
        w2.Part1 = aura2
        w2.Parent = aura2
        aura2.CFrame = newChar.HumanoidRootPart.CFrame

        local p2 = particles:Clone()
        p2.Parent = newChar.HumanoidRootPart

        local bg2 = bg:Clone()
        bg2.Parent = newChar:WaitForChild("Head")
    end)
end)

-- Comandos do Nathan via chat
Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(msg)
        if not isNathan(player) then return end

        local lower = string.lower(msg)

        -- /chuva — spawna 10 brainrots aleatórios
        if lower == "/chuva" then
            for _, p in ipairs(Players:GetPlayers()) do
                notificacao:FireClient(p, "🌧️ NATHAN ATIVOU CHUVA DE BRAINROTS! 🌧️", "sucesso")
            end
            task.spawn(function()
                local raridades = {"Comum","Raro","Épico","Lendário","Mítico"}
                for i = 1, 10 do
                    local r = raridades[math.random(#raridades)]
                    -- Usar o spawner
                    local lista = Config.Brainrots[r]
                    if lista and #lista > 0 then
                        local info = lista[math.random(#lista)]
                        local part = Instance.new("Part")
                        part.Name = "ChuvaRot"
                        part.Size = Vector3.new(3, 3, 3)
                        part.Shape = Enum.PartType.Ball
                        part.Position = Vector3.new(
                            math.random(-50, 50),
                            50 + math.random(0, 20),
                            math.random(-30, 30)
                        )
                        part.Anchored = false
                        part.CanCollide = true
                        for _, rd in ipairs(Config.Raridades) do
                            if rd.nome == r then part.Color = rd.cor break end
                        end
                        part.Material = Enum.Material.Neon
                        part.Parent = workspace.BrainrotsAtivos

                        local bg = Instance.new("BillboardGui")
                        bg.Size = UDim2.new(0,200,0,40)
                        bg.StudsOffset = Vector3.new(0,3,0)
                        bg.AlwaysOnTop = true
                        bg.Parent = part
                        local t = Instance.new("TextLabel")
                        t.Size = UDim2.new(1,0,1,0)
                        t.BackgroundTransparency = 1
                        t.Text = info.nome .. " (" .. r .. ")"
                        t.TextColor3 = Color3.new(1,1,1)
                        t.TextScaled = true
                        t.Font = Enum.Font.GothamBold
                        t.TextStrokeTransparency = 0.3
                        t.Parent = bg

                        task.delay(30, function()
                            if part.Parent then part:Destroy() end
                        end)
                    end
                    task.wait(0.5)
                end
            end)

        -- /divino — spawna o Porco Sagrado
        elseif lower == "/divino" then
            for _, p in ipairs(Players:GetPlayers()) do
                notificacao:FireClient(p, "👑 NATHAN INVOCOU O PORCO SAGRADO DOURADO! 👑", "sucesso")
            end

        -- /boost — dá $10000 para todos
        elseif lower == "/boost" then
            local modData = ReplicatedStorage:WaitForChild("ModPlayerData")
            local getData = ReplicatedStorage:WaitForChild("GetPlayerData")
            for _, p in ipairs(Players:GetPlayers()) do
                local dados = getData:Invoke(p.UserId)
                if dados then
                    modData:Fire(p.UserId, "dinheiro", dados.dinheiro + 10000)
                end
                notificacao:FireClient(p, "💰 NATHAN DEU $10.000 PARA TODOS! 💰", "sucesso")
            end

        -- /evento — ativa evento especial
        elseif lower == "/evento" then
            for _, p in ipairs(Players:GetPlayers()) do
                notificacao:FireClient(p, "🎉 EVENTO DO NATHAN! Brainrots com 2x renda por 2 minutos! 🎉", "sucesso")
            end
        end
    end)
end)
