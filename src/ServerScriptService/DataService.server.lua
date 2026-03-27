-- DataService.server.lua
-- Salva e carrega dados do jogador usando DataStoreService

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local playerStore = DataStoreService:GetDataStore("BrainrotPlayerData_v1")

local DEFAULT_DATA = {
    kills = 0,
    coins = 0,
    highestRound = 0,
    unlockedMobs = {},
}

local loadedData = {}

local function deepCopy(t)
    local copy = {}
    for k, v in t do
        copy[k] = type(v) == "table" and deepCopy(v) or v
    end
    return copy
end

local function loadData(player)
    local key = "player_" .. player.UserId
    local success, data = pcall(function()
        return playerStore:GetAsync(key)
    end)

    if success and data then
        -- Mescla com defaults para garantir novos campos
        for k, v in DEFAULT_DATA do
            if data[k] == nil then
                data[k] = type(v) == "table" and deepCopy(v) or v
            end
        end
        loadedData[player.UserId] = data
    else
        loadedData[player.UserId] = deepCopy(DEFAULT_DATA)
    end

    return loadedData[player.UserId]
end

local function saveData(player)
    local data = loadedData[player.UserId]
    if not data then return end

    local key = "player_" .. player.UserId
    local success, err = pcall(function()
        playerStore:SetAsync(key, data)
    end)

    if not success then
        warn("[DataService] Erro ao salvar dados de", player.Name, ":", err)
    end
end

Players.PlayerAdded:Connect(function(player)
    local data = loadData(player)

    -- Sincroniza leaderstats com dados salvos
    local leaderstats = player:WaitForChild("leaderstats", 10)
    if leaderstats then
        leaderstats:WaitForChild("Kills").Value = data.kills
        leaderstats:WaitForChild("Coins").Value = data.coins
    end
end)

Players.PlayerRemoving:Connect(function(player)
    -- Atualiza dados antes de salvar
    local data = loadedData[player.UserId]
    local leaderstats = player:FindFirstChild("leaderstats")
    if data and leaderstats then
        data.kills = leaderstats:FindFirstChild("Kills") and leaderstats.Kills.Value or data.kills
        data.coins = leaderstats:FindFirstChild("Coins") and leaderstats.Coins.Value or data.coins
    end

    saveData(player)
    loadedData[player.UserId] = nil
end)

-- Salva todos os dados quando o servidor fechar
game:BindToClose(function()
    for _, player in Players:GetPlayers() do
        saveData(player)
    end
end)
