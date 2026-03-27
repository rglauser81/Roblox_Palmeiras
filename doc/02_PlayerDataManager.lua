-- =============================================
-- 02_PlayerDataManager (Script)
-- LOCAL: ServerScriptService > PlayerDataManager
-- =============================================
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- DataStore (salva progresso)
local dataStore = DataStoreService:GetDataStore("BrainrotArenaV1")

-- Dados em memória
local dadosJogadores = {}

-- Remotes
local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage

local function criarRemote(nome, tipo)
    local r = Instance.new(tipo)
    r.Name = nome
    r.Parent = remotes
    return r
end

local atualizarUI = criarRemote("AtualizarUI", "RemoteEvent")
local pedirDesafio = criarRemote("PedirDesafio", "RemoteEvent")
local responderDesafio = criarRemote("ResponderDesafio", "RemoteEvent")
local coletarBrainrot = criarRemote("ColetarBrainrot", "RemoteEvent")
local abrirLoja = criarRemote("AbrirLoja", "RemoteEvent")
local nathanComando = criarRemote("NathanComando", "RemoteEvent")
local notificacao = criarRemote("Notificacao", "RemoteEvent")
local pedirDados = criarRemote("PedirDados", "RemoteFunction")

-- Dados padrão
local function dadosPadrao()
    return {
        dinheiro = 100,
        areasDesbloqueadas = {"Comum"}, -- começa com Comum
        brainrots = {}, -- {nome, raridade, mutacao, renda}
        desafiosCompletos = 0,
        totalColetados = 0,
        slotsBase = 5,
    }
end

-- Carregar dados
local function carregar(player)
    local sucesso, dados = pcall(function()
        return dataStore:GetAsync("player_" .. player.UserId)
    end)
    if sucesso and dados then
        return dados
    end
    return dadosPadrao()
end

-- Salvar dados
local function salvar(player)
    local dados = dadosJogadores[player.UserId]
    if not dados then return end
    pcall(function()
        dataStore:SetAsync("player_" .. player.UserId, dados)
    end)
end

-- Jogador entrou
Players.PlayerAdded:Connect(function(player)
    local dados = carregar(player)
    dadosJogadores[player.UserId] = dados

    -- Enviar dados iniciais ao client
    task.wait(2)
    atualizarUI:FireClient(player, dados)

    -- Leaderstats
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local dinheiroStat = Instance.new("IntValue")
    dinheiroStat.Name = "Dinheiro"
    dinheiroStat.Value = dados.dinheiro
    dinheiroStat.Parent = leaderstats

    local coletadosStat = Instance.new("IntValue")
    coletadosStat.Name = "Brainrots"
    coletadosStat.Value = dados.totalColetados
    coletadosStat.Parent = leaderstats

    -- Renda passiva a cada 1 segundo
    task.spawn(function()
        while player.Parent do
            task.wait(1)
            local d = dadosJogadores[player.UserId]
            if d then
                local rendaTotal = 0
                for _, b in ipairs(d.brainrots) do
                    rendaTotal = rendaTotal + (b.renda or 0)
                end
                if rendaTotal > 0 then
                    d.dinheiro = d.dinheiro + rendaTotal
                    dinheiroStat.Value = d.dinheiro
                end
            end
        end
    end)
end)

-- Jogador saiu
Players.PlayerRemoving:Connect(function(player)
    salvar(player)
    dadosJogadores[player.UserId] = nil
end)

-- Auto-save a cada 60 seg
task.spawn(function()
    while true do
        task.wait(60)
        for _, player in ipairs(Players:GetPlayers()) do
            salvar(player)
        end
    end
end)

-- Função para pegar dados (RemoteFunction)
pedirDados.OnServerInvoke = function(player)
    return dadosJogadores[player.UserId]
end

-- Expor dados para outros scripts do server
local module = {}
module.dadosJogadores = dadosJogadores
module.atualizarUI = atualizarUI
module.notificacao = notificacao

-- Bindable para acesso server-side
local bindable = Instance.new("BindableFunction")
bindable.Name = "GetPlayerData"
bindable.Parent = ReplicatedStorage

bindable.OnInvoke = function(userId)
    return dadosJogadores[userId]
end

-- Bindable para modificar dados
local bindMod = Instance.new("BindableEvent")
bindMod.Name = "ModPlayerData"
bindMod.Parent = ReplicatedStorage

bindMod.Event:Connect(function(userId, campo, valor)
    if dadosJogadores[userId] then
        dadosJogadores[userId][campo] = valor
        local player = Players:GetPlayerByUserId(userId)
        if player then
            -- Atualizar leaderstats
            local ls = player:FindFirstChild("leaderstats")
            if ls then
                if campo == "dinheiro" and ls:FindFirstChild("Dinheiro") then
                    ls.Dinheiro.Value = valor
                end
                if campo == "totalColetados" and ls:FindFirstChild("Brainrots") then
                    ls.Brainrots.Value = valor
                end
            end
            atualizarUI:FireClient(player, dadosJogadores[userId])
        end
    end
end)
