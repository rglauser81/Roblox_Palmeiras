-- =============================================
-- 06_ClientUI (LocalScript)
-- LOCAL: StarterPlayer > StarterPlayerScripts > ClientUI
-- =============================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local atualizarUI = remotes:WaitForChild("AtualizarUI")
local pedirDesafio = remotes:WaitForChild("PedirDesafio")
local responderDesafio = remotes:WaitForChild("ResponderDesafio")
local notificacao = remotes:WaitForChild("Notificacao")
local pedirDados = remotes:WaitForChild("PedirDados")

-- =======================
-- SCREEN GUI PRINCIPAL
-- =======================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- =======================
-- HUD — Dinheiro e Info
-- =======================
local hudFrame = Instance.new("Frame")
hudFrame.Name = "HUD"
hudFrame.Size = UDim2.new(0, 280, 0, 90)
hudFrame.Position = UDim2.new(0, 10, 0, 10)
hudFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
hudFrame.BackgroundTransparency = 0.3
hudFrame.Parent = screenGui

local hudCorner = Instance.new("UICorner")
hudCorner.CornerRadius = UDim.new(0, 12)
hudCorner.Parent = hudFrame

local dinheiroLabel = Instance.new("TextLabel")
dinheiroLabel.Name = "Dinheiro"
dinheiroLabel.Size = UDim2.new(1, -20, 0, 35)
dinheiroLabel.Position = UDim2.new(0, 10, 0, 5)
dinheiroLabel.BackgroundTransparency = 1
dinheiroLabel.Text = "💰 $0"
dinheiroLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
dinheiroLabel.TextScaled = true
dinheiroLabel.Font = Enum.Font.GothamBold
dinheiroLabel.TextXAlignment = Enum.TextXAlignment.Left
dinheiroLabel.Parent = hudFrame

local infoLabel = Instance.new("TextLabel")
infoLabel.Name = "Info"
infoLabel.Size = UDim2.new(1, -20, 0, 22)
infoLabel.Position = UDim2.new(0, 10, 0, 38)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "🧠 0 brainrots • 📦 0/5 slots"
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.TextScaled = true
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Parent = hudFrame

local rendaLabel = Instance.new("TextLabel")
rendaLabel.Name = "Renda"
rendaLabel.Size = UDim2.new(1, -20, 0, 20)
rendaLabel.Position = UDim2.new(0, 10, 0, 62)
rendaLabel.BackgroundTransparency = 1
rendaLabel.Text = "📈 Renda: $0/s"
rendaLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
rendaLabel.TextScaled = true
rendaLabel.Font = Enum.Font.Gotham
rendaLabel.TextXAlignment = Enum.TextXAlignment.Left
rendaLabel.Parent = hudFrame

-- =======================
-- TIMER CELESTIAL/DIVINO
-- =======================
local timerFrame = Instance.new("Frame")
timerFrame.Name = "Timers"
timerFrame.Size = UDim2.new(0, 220, 0, 55)
timerFrame.Position = UDim2.new(1, -230, 0, 10)
timerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
timerFrame.BackgroundTransparency = 0.3
timerFrame.Parent = screenGui

local timerCorner = Instance.new("UICorner")
timerCorner.CornerRadius = UDim.new(0, 12)
timerCorner.Parent = timerFrame

local celestialTimer = Instance.new("TextLabel")
celestialTimer.Size = UDim2.new(1, -10, 0, 22)
celestialTimer.Position = UDim2.new(0, 5, 0, 5)
celestialTimer.BackgroundTransparency = 1
celestialTimer.Text = "🌟 Celestial: 4:00"
celestialTimer.TextColor3 = Color3.fromRGB(135, 206, 250)
celestialTimer.TextScaled = true
celestialTimer.Font = Enum.Font.GothamBold
celestialTimer.TextXAlignment = Enum.TextXAlignment.Left
celestialTimer.Parent = timerFrame

local divinoTimer = Instance.new("TextLabel")
divinoTimer.Size = UDim2.new(1, -10, 0, 22)
divinoTimer.Position = UDim2.new(0, 5, 0, 28)
divinoTimer.BackgroundTransparency = 1
divinoTimer.Text = "👑 Divino: 60:00"
divinoTimer.TextColor3 = Color3.fromRGB(255, 215, 0)
divinoTimer.TextScaled = true
divinoTimer.Font = Enum.Font.GothamBold
divinoTimer.TextXAlignment = Enum.TextXAlignment.Left
divinoTimer.Parent = timerFrame

-- Countdown dos timers
task.spawn(function()
    local celSeg = 240 -- 4 min
    local divSeg = 3600 -- 1 hora
    while true do
        task.wait(1)
        celSeg = celSeg - 1
        divSeg = divSeg - 1
        if celSeg <= 0 then celSeg = 240 end
        if divSeg <= 0 then divSeg = 3600 end

        local celMin = math.floor(celSeg / 60)
        local celS = celSeg % 60
        celestialTimer.Text = string.format("🌟 Celestial: %d:%02d", celMin, celS)

        local divMin = math.floor(divSeg / 60)
        local divS = divSeg % 60
        divinoTimer.Text = string.format("👑 Divino: %d:%02d", divMin, divS)
    end
end)

-- =======================
-- POPUP DE DESAFIO
-- =======================
local desafioFrame = Instance.new("Frame")
desafioFrame.Name = "DesafioPopup"
desafioFrame.Size = UDim2.new(0, 420, 0, 280)
desafioFrame.Position = UDim2.new(0.5, -210, 0.5, -140)
desafioFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
desafioFrame.BackgroundTransparency = 0.1
desafioFrame.Visible = false
desafioFrame.Parent = screenGui
desafioFrame.ZIndex = 10

local desCorner = Instance.new("UICorner")
desCorner.CornerRadius = UDim.new(0, 16)
desCorner.Parent = desafioFrame

local desStroke = Instance.new("UIStroke")
desStroke.Thickness = 2
desStroke.Color = Color3.fromRGB(100, 100, 255)
desStroke.Parent = desafioFrame

local desTitulo = Instance.new("TextLabel")
desTitulo.Name = "Titulo"
desTitulo.Size = UDim2.new(1, -20, 0, 40)
desTitulo.Position = UDim2.new(0, 10, 0, 10)
desTitulo.BackgroundTransparency = 1
desTitulo.Text = "🧠 DESAFIO"
desTitulo.TextColor3 = Color3.fromRGB(255, 255, 255)
desTitulo.TextScaled = true
desTitulo.Font = Enum.Font.GothamBold
desTitulo.ZIndex = 11
desTitulo.Parent = desafioFrame

local desPergunta = Instance.new("TextLabel")
desPergunta.Name = "Pergunta"
desPergunta.Size = UDim2.new(1, -30, 0, 80)
desPergunta.Position = UDim2.new(0, 15, 0, 55)
desPergunta.BackgroundTransparency = 1
desPergunta.Text = ""
desPergunta.TextColor3 = Color3.fromRGB(200, 200, 255)
desPergunta.TextScaled = true
desPergunta.TextWrapped = true
desPergunta.Font = Enum.Font.Gotham
desPergunta.ZIndex = 11
desPergunta.Parent = desafioFrame

local desInput = Instance.new("TextBox")
desInput.Name = "Resposta"
desInput.Size = UDim2.new(0.7, 0, 0, 40)
desInput.Position = UDim2.new(0.15, 0, 0, 150)
desInput.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
desInput.TextColor3 = Color3.new(1, 1, 1)
desInput.PlaceholderText = "Digite sua resposta..."
desInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
desInput.TextScaled = true
desInput.Font = Enum.Font.Gotham
desInput.ClearTextOnFocus = true
desInput.ZIndex = 11
desInput.Parent = desafioFrame

local desInputCorner = Instance.new("UICorner")
desInputCorner.CornerRadius = UDim.new(0, 8)
desInputCorner.Parent = desInput

local desBotao = Instance.new("TextButton")
desBotao.Name = "Enviar"
desBotao.Size = UDim2.new(0.5, 0, 0, 40)
desBotao.Position = UDim2.new(0.25, 0, 0, 205)
desBotao.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
desBotao.TextColor3 = Color3.new(1, 1, 1)
desBotao.Text = "✅ RESPONDER"
desBotao.TextScaled = true
desBotao.Font = Enum.Font.GothamBold
desBotao.ZIndex = 11
desBotao.Parent = desafioFrame

local desBotaoCorner = Instance.new("UICorner")
desBotaoCorner.CornerRadius = UDim.new(0, 8)
desBotaoCorner.Parent = desBotao

local desFechar = Instance.new("TextButton")
desFechar.Size = UDim2.new(0, 30, 0, 30)
desFechar.Position = UDim2.new(1, -35, 0, 5)
desFechar.BackgroundTransparency = 1
desFechar.Text = "✕"
desFechar.TextColor3 = Color3.fromRGB(200, 100, 100)
desFechar.TextScaled = true
desFechar.ZIndex = 11
desFechar.Parent = desafioFrame

desFechar.MouseButton1Click:Connect(function()
    desafioFrame.Visible = false
end)

local nivelDesafioAtual = 0

-- Receber desafio do server
pedirDesafio.OnClientEvent:Connect(function(data)
    if type(data) == "table" then
        nivelDesafioAtual = data.nivel
        desTitulo.Text = "🧠 DESAFIO — Desbloquear: " .. data.area
        desTitulo.TextColor3 = data.cor
        desStroke.Color = data.cor
        desPergunta.Text = data.pergunta
        desInput.Text = ""
        desafioFrame.Visible = true
    end
end)

-- Enviar resposta
desBotao.MouseButton1Click:Connect(function()
    if desInput.Text ~= "" then
        responderDesafio:FireServer(nivelDesafioAtual, desInput.Text)
        desafioFrame.Visible = false
    end
end)

-- Também enviar com Enter
desInput.FocusLost:Connect(function(enterPressed)
    if enterPressed and desInput.Text ~= "" then
        responderDesafio:FireServer(nivelDesafioAtual, desInput.Text)
        desafioFrame.Visible = false
    end
end)

-- =======================
-- SISTEMA DE NOTIFICAÇÕES
-- =======================
local notiFrame = Instance.new("Frame")
notiFrame.Name = "Notificacoes"
notiFrame.Size = UDim2.new(0, 400, 0, 300)
notiFrame.Position = UDim2.new(0.5, -200, 0, 80)
notiFrame.BackgroundTransparency = 1
notiFrame.Parent = screenGui
notiFrame.ZIndex = 20

local notiLayout = Instance.new("UIListLayout")
notiLayout.SortOrder = Enum.SortOrder.LayoutOrder
notiLayout.Padding = UDim.new(0, 5)
notiLayout.VerticalAlignment = Enum.VerticalAlignment.Top
notiLayout.Parent = notiFrame

local corNotificacao = {
    sucesso = Color3.fromRGB(30, 120, 50),
    erro = Color3.fromRGB(150, 30, 30),
    info = Color3.fromRGB(30, 80, 150),
}

notificacao.OnClientEvent:Connect(function(mensagem, tipo)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 35)
    label.BackgroundColor3 = corNotificacao[tipo] or corNotificacao.info
    label.BackgroundTransparency = 0.2
    label.Text = "  " .. mensagem
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 21
    label.Parent = notiFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = label

    -- Fade out
    task.delay(3, function()
        local tween = TweenService:Create(label, TweenInfo.new(0.5), {BackgroundTransparency = 1, TextTransparency = 1})
        tween:Play()
        tween.Completed:Connect(function()
            label:Destroy()
        end)
    end)
end)

-- =======================
-- ATUALIZAR HUD
-- =======================
atualizarUI.OnClientEvent:Connect(function(dados)
    if not dados then return end

    -- Formatar dinheiro
    local function formatNum(n)
        if n >= 1000000 then return string.format("%.1fM", n/1000000) end
        if n >= 1000 then return string.format("%.1fK", n/1000) end
        return tostring(n)
    end

    dinheiroLabel.Text = "💰 $" .. formatNum(dados.dinheiro)

    local totalBR = #dados.brainrots
    infoLabel.Text = "🧠 " .. totalBR .. " brainrots • 📦 " .. totalBR .. "/" .. dados.slotsBase .. " slots"

    -- Calcular renda
    local rendaTotal = 0
    for _, b in ipairs(dados.brainrots) do
        rendaTotal = rendaTotal + (b.renda or 0)
    end
    rendaLabel.Text = "📈 Renda: $" .. formatNum(rendaTotal) .. "/s"
end)

-- Pedir dados iniciais
task.spawn(function()
    task.wait(3)
    local dados = pedirDados:InvokeServer()
    if dados then
        atualizarUI.OnClientEvent:Fire(dados)
    end
end)
