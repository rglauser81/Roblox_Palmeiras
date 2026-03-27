-- =============================================
-- 03_DesafioSystem (Script)
-- LOCAL: ServerScriptService > DesafioSystem
-- =============================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Aguardar módulos
local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GameConfig"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local responderDesafio = remotes:WaitForChild("ResponderDesafio")
local pedirDesafio = remotes:WaitForChild("PedirDesafio")
local notificacao = remotes:WaitForChild("Notificacao")
local modData = ReplicatedStorage:WaitForChild("ModPlayerData")
local getData = ReplicatedStorage:WaitForChild("GetPlayerData")
local atualizarUI = remotes:WaitForChild("AtualizarUI")

-- Pool de desafios extras (para variação)
local desafiosExtras = {
    -- Nível 1
    {nivel=1, tipo="matematica", pergunta="15 + 27 = ???", resposta="42"},
    {nivel=1, tipo="logica", pergunta="Qual o próximo? 5, 10, 20, 40, ???", resposta="80"},
    -- Nível 2
    {nivel=2, tipo="matematica", pergunta="12 × 12 = ???", resposta="144"},
    {nivel=2, tipo="logica", pergunta="Padrão: AB, CD, EF, ???", resposta="GH"},
    -- Nível 3
    {nivel=3, tipo="matematica", pergunta="256 ÷ 16 = ???", resposta="16"},
    {nivel=3, tipo="logica", pergunta="3 gatos pegam 3 ratos em 3 min. 100 gatos pegam 100 ratos em ??? min", resposta="3"},
    -- Nível 4
    {nivel=4, tipo="matematica", pergunta="Fatorial de 5 (5!) = ???", resposta="120"},
    {nivel=4, tipo="logica", pergunta="Tenho 6 faces mas não sou vivo. Tenho 21 olhos mas não enxergo. O que sou?", resposta="dado"},
    -- Nível 5
    {nivel=5, tipo="matematica", pergunta="Primo mais próximo de 100 (maior)?", resposta="101"},
    -- Nível 6
    {nivel=6, tipo="logica", pergunta="Binário 11001 em decimal = ???", resposta="25"},
    -- Nível 7
    {nivel=7, tipo="logica", pergunta="Triângulo de Pascal, 5ª linha, 3º número?", resposta="6"},
}

-- Combinar desafios
local todosDesafios = {}
for _, d in ipairs(Config.Desafios) do
    table.insert(todosDesafios, d)
end
for _, d in ipairs(desafiosExtras) do
    table.insert(todosDesafios, d)
end

-- Pegar desafio aleatório para o nível
local function pegarDesafio(nivel)
    local candidatos = {}
    for _, d in ipairs(todosDesafios) do
        if d.nivel == nivel then
            table.insert(candidatos, d)
        end
    end
    if #candidatos == 0 then
        return todosDesafios[1]
    end
    return candidatos[math.random(#candidatos)]
end

-- Jogador pede desafio (ao tocar no portal da área)
pedirDesafio.OnServerEvent:Connect(function(player, nivelPedido)
    local dados = getData:Invoke(player.UserId)
    if not dados then return end

    local nivelAtual = dados.desafiosCompletos
    local proximoNivel = nivelAtual + 1

    if nivelPedido ~= proximoNivel then
        notificacao:FireClient(player, "Você precisa completar o nível " .. proximoNivel .. " primeiro!", "erro")
        return
    end

    if proximoNivel > #Config.Raridades - 1 then
        notificacao:FireClient(player, "Você já desbloqueou todas as áreas!", "info")
        return
    end

    local desafio = pegarDesafio(proximoNivel)
    -- Enviar desafio pro client
    pedirDesafio:FireClient(player, {
        nivel = proximoNivel,
        tipo = desafio.tipo,
        pergunta = desafio.pergunta,
        area = Config.Raridades[proximoNivel + 1].nome,
        cor = Config.Raridades[proximoNivel + 1].cor,
    })
end)

-- Jogador responde desafio
responderDesafio.OnServerEvent:Connect(function(player, nivelRespondido, resposta)
    local dados = getData:Invoke(player.UserId)
    if not dados then return end

    local nivelAtual = dados.desafiosCompletos
    if nivelRespondido ~= nivelAtual + 1 then return end

    -- Verificar resposta
    local desafiosCandidatos = {}
    for _, d in ipairs(todosDesafios) do
        if d.nivel == nivelRespondido then
            table.insert(desafiosCandidatos, d)
        end
    end

    local acertou = false
    for _, d in ipairs(desafiosCandidatos) do
        if string.lower(tostring(resposta)) == string.lower(d.resposta) then
            acertou = true
            break
        end
    end

    if acertou then
        -- Desbloquear nova área
        local novaArea = Config.Raridades[nivelRespondido + 1].nome
        dados.desafiosCompletos = nivelRespondido
        table.insert(dados.areasDesbloqueadas, novaArea)

        modData:Fire(player.UserId, "desafiosCompletos", dados.desafiosCompletos)
        modData:Fire(player.UserId, "areasDesbloqueadas", dados.areasDesbloqueadas)

        -- Notificar todos
        notificacao:FireClient(player, "🎉 ÁREA " .. string.upper(novaArea) .. " DESBLOQUEADA!", "sucesso")

        -- Anúncio global
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                notificacao:FireClient(p, player.Name .. " desbloqueou a área " .. novaArea .. "!", "info")
            end
        end

        -- Abrir porta/barreira no workspace
        local barreira = workspace:FindFirstChild("Barreira_" .. novaArea)
        if barreira then
            barreira.Transparency = 0.8
            barreira.CanCollide = false
        end

        atualizarUI:FireClient(player, dados)
    else
        notificacao:FireClient(player, "❌ Resposta errada! Tente novamente.", "erro")
    end
end)

-- Criar portais de desafio no campo
task.spawn(function()
    task.wait(3) -- esperar workspace carregar

    local campoDesafios = workspace:FindFirstChild("CampoDesafios")
    if not campoDesafios then
        campoDesafios = Instance.new("Folder")
        campoDesafios.Name = "CampoDesafios"
        campoDesafios.Parent = workspace
    end

    for i = 1, #Config.Raridades - 1 do
        local raridade = Config.Raridades[i + 1]

        -- Portal de desafio
        local portal = Instance.new("Part")
        portal.Name = "Portal_" .. raridade.nome
        portal.Size = Vector3.new(8, 12, 2)
        portal.Position = Vector3.new(-70 + (i * 20), 22, 0) -- espaçados no campo
        portal.Color = raridade.cor
        portal.Material = Enum.Material.Neon
        portal.Anchored = true
        portal.CanCollide = false
        portal.Transparency = 0.3
        portal.Parent = campoDesafios

        -- Texto do portal
        local bg = Instance.new("BillboardGui")
        bg.Size = UDim2.new(0, 200, 0, 80)
        bg.StudsOffset = Vector3.new(0, 8, 0)
        bg.AlwaysOnTop = true
        bg.Parent = portal

        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 0.5, 0)
        txt.BackgroundTransparency = 1
        txt.Text = "🧠 " .. raridade.nome
        txt.TextColor3 = raridade.cor
        txt.TextScaled = true
        txt.Font = Enum.Font.GothamBold
        txt.Parent = bg

        local txt2 = Instance.new("TextLabel")
        txt2.Size = UDim2.new(1, 0, 0.5, 0)
        txt2.Position = UDim2.new(0, 0, 0.5, 0)
        txt2.BackgroundTransparency = 1
        txt2.Text = "Toque para desafio"
        txt2.TextColor3 = Color3.new(1, 1, 1)
        txt2.TextScaled = true
        txt2.Font = Enum.Font.Gotham
        txt2.Parent = bg

        -- Barreira da área
        local barreira = Instance.new("Part")
        barreira.Name = "Barreira_" .. raridade.nome
        barreira.Size = Vector3.new(1, 15, 30)
        barreira.Position = Vector3.new(-70 + (i * 20) + 5, 22, 0)
        barreira.Color = raridade.cor
        barreira.Material = Enum.Material.ForceField
        barreira.Anchored = true
        barreira.CanCollide = true
        barreira.Transparency = 0.5
        barreira.Parent = campoDesafios

        -- Detectar toque no portal
        portal.Touched:Connect(function(hit)
            local hum = hit.Parent:FindFirstChild("Humanoid")
            if not hum then return end
            local player = Players:GetPlayerFromCharacter(hit.Parent)
            if not player then return end
            pedirDesafio:FireClient(player, i)
        end)
    end
end)
