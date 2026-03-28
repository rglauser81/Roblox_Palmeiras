-- CoinRainService.server.lua
-- Moedas douradas caem pelo estadio periodicamente
-- Jogadores coletam ao tocar (como na imagem do Allianz Brainrot Arena)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local CR = GameConfig.COIN_RAIN

if not CR or not CR.ENABLED then return end

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- Debounce por jogador (evita coleta multipla da mesma moeda)
local collecting = {}

local function spawnCoin(position)
    local coin = Instance.new("Part")
    coin.Name = "ArenaGoldCoin"
    coin.Shape = Enum.PartType.Cylinder
    coin.Size = Vector3.new(0.3, CR.COIN_SIZE, CR.COIN_SIZE)
    coin.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
    coin.BrickColor = BrickColor.new("Gold")
    coin.Material = Enum.Material.Glass
    coin.Anchored = false
    coin.CanCollide = false

    -- Brilho
    local light = Instance.new("PointLight")
    light.Range = 8
    light.Brightness = 1.5
    light.Color = Color3.fromRGB(255, 215, 0)
    light.Parent = coin

    -- Rotacao visual
    local angVel = Instance.new("BodyAngularVelocity")
    angVel.AngularVelocity = Vector3.new(0, 6, 0)
    angVel.MaxTorque = Vector3.new(0, 5000, 0)
    angVel.P = 1000
    angVel.Parent = coin

    -- Colisao para coletar
    coin.Touched:Connect(function(hit)
        if not coin.Parent then return end
        local character = hit.Parent
        local player = Players:GetPlayerFromCharacter(character)
        if not player then return end

        -- Debounce
        if collecting[coin] then return end
        collecting[coin] = true

        -- Recompensa
        local ls = player:FindFirstChild("leaderstats")
        if ls and ls:FindFirstChild("Coins") then
            local profile = player:FindFirstChild("PlayerProfile")
            local mult = 1
            if profile and profile:FindFirstChild("CoinMultiplier") then
                mult = profile.CoinMultiplier.Value
            end
            ls.Coins.Value += math.floor(CR.COLLECT_REWARD * mult)
        end

        coin:Destroy()
    end)

    coin.Parent = workspace

    Debris:AddItem(coin, CR.COIN_LIFETIME)

    return coin
end

local function burstCoins()
    local S = GameConfig.STADIUM
    local fieldL = S.FIELD_LENGTH
    local fieldW = S.FIELD_WIDTH

    for _ = 1, CR.COINS_PER_BURST do
        local x = math.random(-fieldL/2, fieldL/2)
        local z = math.random(-fieldW/2, fieldW/2)
        local y = (S.FIELD_Y or 0) + math.random(20, 40)
        spawnCoin(Vector3.new(x, y, z))
    end
end

-- Loop principal de chuva de moedas
task.spawn(function()
    -- Aguarda o estadio ser construido
    task.wait(5)

    while true do
        if #Players:GetPlayers() > 0 then
            burstCoins()
        end
        task.wait(CR.BURST_INTERVAL)
    end
end)

print("[CoinRainService] Chuva de moedas ativada na Allianz Brainrot Arena!")
