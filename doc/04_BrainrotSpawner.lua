-- =============================================
-- 04_BrainrotSpawner (Script)
-- LOCAL: ServerScriptService > BrainrotSpawner
-- =============================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GameConfig"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local coletarBrainrot = remotes:WaitForChild("ColetarBrainrot")
local notificacao = remotes:WaitForChild("Notificacao")
local modData = ReplicatedStorage:WaitForChild("ModPlayerData")
local getData = ReplicatedStorage:WaitForChild("GetPlayerData")
local atualizarUI = remotes:WaitForChild("AtualizarUI")

-- Pasta para brainrots no mundo
local brainrotFolder = Instance.new("Folder")
brainrotFolder.Name = "BrainrotsAtivos"
brainrotFolder.Parent = workspace

-- Zonas de spawn por raridade
local zonaSpawn = {
    Comum      = {min = Vector3.new(-40, 16, -25), max = Vector3.new(-20, 16, 25)},
    Raro       = {min = Vector3.new(-20, 16, -25), max = Vector3.new(0, 16, 25)},
    ["Épico"]  = {min = Vector3.new(0, 16, -25),   max = Vector3.new(20, 16, 25)},
    ["Lendário"]={min = Vector3.new(20, 16, -25),  max = Vector3.new(40, 16, 25)},
    ["Mítico"] = {min = Vector3.new(40, 16, -25),  max = Vector3.new(60, 16, 25)},
    Secreto    = {min = Vector3.new(60, 16, -25),  max = Vector3.new(80, 16, 25)},
    Celestial  = {min = Vector3.new(-30, 36, -25), max = Vector3.new(30, 36, 25)}, -- andar superior
    Divino     = {min = Vector3.new(-10, 40, -10), max = Vector3.new(10, 40, 10)}, -- centro alto
}

-- Posição aleatória na zona
local function posAleatoria(zona)
    if not zona then return Vector3.new(0, 16, 0) end
    return Vector3.new(
        math.random() * (zona.max.X - zona.min.X) + zona.min.X,
        zona.min.Y,
        math.random() * (zona.max.Z - zona.min.Z) + zona.min.Z
    )
end

-- Sortear mutação
local function sortearMutacao()
    local roll = math.random() * 100
    local acumulado = 0
    for _, mut in ipairs(Config.Mutacoes) do
        acumulado = acumulado + mut.chance
        if roll <= acumulado then
            return mut
        end
    end
    return nil -- sem mutação
end

-- Criar efeito visual de mutação
local function aplicarEfeitoMutacao(part, mutacao)
    if not mutacao then return end

    if mutacao.nome == "Ouro" then
        part.Color = Color3.fromRGB(255, 215, 0)
        part.Material = Enum.Material.Neon
        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(255, 215, 0)
        light.Brightness = 2
        light.Range = 12
        light.Parent = part

    elseif mutacao.nome == "Céu Alviverde" then
        part.Color = Color3.fromRGB(0, 100, 0)
        -- Anjinhos orbitando
        for j = 1, 3 do
            local anjo = Instance.new("Part")
            anjo.Name = "Anjinho" .. j
            anjo.Size = Vector3.new(1, 1.5, 0.5)
            anjo.Shape = Enum.PartType.Ball
            anjo.Color = Color3.fromRGB(255, 255, 255)
            anjo.Material = Enum.Material.Neon
            anjo.CanCollide = false
            anjo.Anchored = true
            anjo.Transparency = 0.3
            anjo.Parent = part

            -- Asas do anjo (mini parts)
            local asa = Instance.new("Part")
            asa.Size = Vector3.new(0.2, 1, 1.5)
            asa.Color = Color3.fromRGB(200, 255, 200)
            asa.Material = Enum.Material.Neon
            asa.CanCollide = false
            asa.Anchored = true
            asa.Transparency = 0.4
            asa.Parent = part
            asa.Name = "Asa" .. j

            -- Billboard com emoji
            local bg = Instance.new("BillboardGui")
            bg.Size = UDim2.new(0, 30, 0, 30)
            bg.AlwaysOnTop = true
            bg.Parent = anjo
            local t = Instance.new("TextLabel")
            t.Size = UDim2.new(1,0,1,0)
            t.BackgroundTransparency = 1
            t.Text = "👼"
            t.TextScaled = true
            t.Parent = bg
        end

        -- Animação de órbita
        task.spawn(function()
            local angulos = {0, 120, 240}
            while part.Parent do
                for j = 1, 3 do
                    local anjo = part:FindFirstChild("Anjinho" .. j)
                    local asa = part:FindFirstChild("Asa" .. j)
                    if anjo then
                        angulos[j] = angulos[j] + 2
                        local rad = math.rad(angulos[j])
                        local offset = Vector3.new(math.cos(rad) * 4, 1 + math.sin(rad * 2) * 0.5, math.sin(rad) * 4)
                        anjo.Position = part.Position + offset
                        if asa then
                            asa.Position = anjo.Position + Vector3.new(0, 0.3, 0)
                        end
                    end
                end
                task.wait(0.03)
            end
        end)

    elseif mutacao.nome == "Diamante" then
        part.Color = Color3.fromRGB(185, 242, 255)
        part.Material = Enum.Material.Glass
        part.Reflectance = 0.8
        local sparkle = Instance.new("Sparkles")
        sparkle.SparkleColor = Color3.fromRGB(200, 240, 255)
        sparkle.Parent = part
        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(185, 242, 255)
        light.Brightness = 3
        light.Range = 16
        light.Parent = part
    end
end

-- Spawnar um brainrot no mundo
local function spawnarBrainrot(raridade)
    local lista = Config.Brainrots[raridade]
    if not lista or #lista == 0 then return end

    local info = lista[math.random(#lista)]
    local zona = zonaSpawn[raridade]
    local pos = posAleatoria(zona)

    -- Sortear mutação
    local mutacao = sortearMutacao()
    local rendaFinal = info.renda
    local nomeFinal = info.nome
    if mutacao then
        rendaFinal = info.renda * mutacao.multiplicador
        nomeFinal = "✨ " .. info.nome .. " [" .. mutacao.nome .. "]"
    end

    -- Criar part visual
    local part = Instance.new("Part")
    part.Name = "Brainrot_" .. raridade
    part.Size = Vector3.new(4, 4, 4)
    part.Shape = Enum.PartType.Ball
    part.Position = pos
    part.Anchored = true
    part.CanCollide = false

    -- Cor base da raridade
    for _, r in ipairs(Config.Raridades) do
        if r.nome == raridade then
            part.Color = r.cor
            break
        end
    end
    part.Material = Enum.Material.Neon

    -- Aplicar mutação visual
    aplicarEfeitoMutacao(part, mutacao)

    -- Partículas
    local particles = Instance.new("ParticleEmitter")
    particles.Rate = 15
    particles.Lifetime = NumberRange.new(0.5, 1)
    particles.Speed = NumberRange.new(1, 3)
    particles.Color = ColorSequence.new(part.Color)
    particles.Size = NumberSequence.new(0.3, 0)
    particles.Parent = part

    -- Billboard com nome
    local bg = Instance.new("BillboardGui")
    bg.Size = UDim2.new(0, 250, 0, 60)
    bg.StudsOffset = Vector3.new(0, 4, 0)
    bg.AlwaysOnTop = true
    bg.Parent = part

    local txtNome = Instance.new("TextLabel")
    txtNome.Size = UDim2.new(1, 0, 0.6, 0)
    txtNome.BackgroundTransparency = 1
    txtNome.Text = nomeFinal
    txtNome.TextColor3 = Color3.new(1, 1, 1)
    txtNome.TextScaled = true
    txtNome.Font = Enum.Font.GothamBold
    txtNome.TextStrokeTransparency = 0.3
    txtNome.Parent = bg

    local txtInfo = Instance.new("TextLabel")
    txtInfo.Size = UDim2.new(1, 0, 0.4, 0)
    txtInfo.Position = UDim2.new(0, 0, 0.6, 0)
    txtInfo.BackgroundTransparency = 1
    txtInfo.Text = "💰 $" .. rendaFinal .. "/s • " .. raridade
    txtInfo.TextColor3 = Color3.fromRGB(255, 255, 150)
    txtInfo.TextScaled = true
    txtInfo.Font = Enum.Font.Gotham
    txtInfo.TextStrokeTransparency = 0.5
    txtInfo.Parent = bg

    -- Animação flutuante
    task.spawn(function()
        local baseY = pos.Y
        local t = 0
        while part.Parent do
            t = t + 0.05
            part.Position = Vector3.new(pos.X, baseY + math.sin(t) * 1.5, pos.Z)
            task.wait(0.03)
        end
    end)

    -- Guardar info no part
    local infoValue = Instance.new("StringValue")
    infoValue.Name = "BrainrotInfo"
    infoValue.Value = game:GetService("HttpService"):JSONEncode({
        nome = info.nome,
        raridade = raridade,
        renda = rendaFinal,
        mutacao = mutacao and mutacao.nome or "Nenhuma",
    })
    infoValue.Parent = part

    part.Parent = brainrotFolder

    -- Toque para coletar
    part.Touched:Connect(function(hit)
        local hum = hit.Parent:FindFirstChild("Humanoid")
        if not hum then return end
        local player = Players:GetPlayerFromCharacter(hit.Parent)
        if not player then return end

        local dados = getData:Invoke(player.UserId)
        if not dados then return end

        -- Verificar se tem a área desbloqueada
        local temArea = false
        for _, a in ipairs(dados.areasDesbloqueadas) do
            if a == raridade then
                temArea = true
                break
            end
        end
        if not temArea then
            notificacao:FireClient(player, "🔒 Área " .. raridade .. " bloqueada! Complete o desafio.", "erro")
            return
        end

        -- Verificar slots
        if #dados.brainrots >= dados.slotsBase then
            notificacao:FireClient(player, "📦 Base cheia! Compre mais slots na loja.", "erro")
            return
        end

        -- Coletar
        local brainrotData = {
            nome = info.nome,
            raridade = raridade,
            renda = rendaFinal,
            mutacao = mutacao and mutacao.nome or "Nenhuma",
        }
        table.insert(dados.brainrots, brainrotData)
        dados.totalColetados = dados.totalColetados + 1

        modData:Fire(player.UserId, "brainrots", dados.brainrots)
        modData:Fire(player.UserId, "totalColetados", dados.totalColetados)

        -- Destruir no mundo
        part:Destroy()

        -- Notificação
        local msgMut = ""
        if mutacao then
            msgMut = " com mutação " .. mutacao.nome .. "!"
        end
        notificacao:FireClient(player, "✅ " .. info.nome .. " coletado!" .. msgMut, "sucesso")

        -- Anúncio especial para raridades altas
        if raridade == "Celestial" or raridade == "Divino" or raridade == "Secreto" then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player then
                    notificacao:FireClient(p, "⚡ " .. player.Name .. " coletou um " .. raridade .. ": " .. info.nome .. "!", "info")
                end
            end
        end
    end)

    -- Despawnar depois de 60s se ninguém pegar (exceto Divino)
    local tempoVida = 60
    if raridade == "Divino" then tempoVida = 120 end
    if raridade == "Celestial" then tempoVida = 90 end

    task.delay(tempoVida, function()
        if part.Parent then
            part:Destroy()
        end
    end)
end

-- SISTEMA DE SPAWN CONTÍNUO
task.spawn(function()
    task.wait(5) -- esperar jogo carregar

    -- Spawn loops por raridade
    for raridade, timer in pairs(Config.SpawnTimers) do
        task.spawn(function()
            while true do
                task.wait(timer)
                local maxAtivos = 5
                if raridade == "Celestial" then maxAtivos = 1 end
                if raridade == "Divino" then maxAtivos = 1 end

                -- Contar ativos dessa raridade
                local ativos = 0
                for _, child in ipairs(brainrotFolder:GetChildren()) do
                    if child.Name == "Brainrot_" .. raridade then
                        ativos = ativos + 1
                    end
                end

                if ativos < maxAtivos then
                    spawnarBrainrot(raridade)

                    -- Anúncio especial
                    if raridade == "Celestial" then
                        for _, p in ipairs(Players:GetPlayers()) do
                            notificacao:FireClient(p, "🌟 Um CELESTIAL apareceu no estádio! Corra!", "info")
                        end
                    elseif raridade == "Divino" then
                        for _, p in ipairs(Players:GetPlayers()) do
                            notificacao:FireClient(p, "👑✨ UM DIVINO SURGIU!! O PORCO SAGRADO DOURADO DESCEU AO ALLIANZ! ✨👑", "sucesso")
                        end
                    end
                end
            end
        end)
    end
end)
