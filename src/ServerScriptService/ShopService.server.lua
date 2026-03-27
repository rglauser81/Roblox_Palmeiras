-- ShopService.server.lua
-- 🛍️ Loja do servidor: validação, compra e entrega de itens

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local Remotes
local activeBoosted = {}   -- { [userId] = { boostId = true } }

-- Aguarda Remotes criados pelo Remotes.server.lua
local function getRemotes()
    if not Remotes then
        Remotes = ReplicatedStorage:WaitForChild("Remotes")
    end
    return Remotes
end

-- ============================================================
-- Utilitários
-- ============================================================

local function getCoins(player)
    local ls = player:FindFirstChild("leaderstats")
    return ls and ls:FindFirstChild("Coins") and ls.Coins.Value or 0
end

local function addCoins(player, amount)
    local ls = player:FindFirstChild("leaderstats")
    if ls and ls:FindFirstChild("Coins") then
        ls.Coins.Value = math.max(0, ls.Coins.Value + amount)
    end
end

local function getItemById(id)
    for _, item in GameConfig.SHOP_ITEMS do
        if item.id == id then return item end
    end
    return nil
end

local function isCreator(player)
    local profile = player:FindFirstChild("PlayerProfile")
    return profile and profile:FindFirstChild("IsCreator") and profile.IsCreator.Value
end

-- ============================================================
-- Entrega de itens por categoria
-- ============================================================

local function deliverWeapon(player, item)
    local char = player.Character
    if not char then return false end

    -- Clona a ferramenta de ReplicatedStorage.Items se existir
    local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
    if itemsFolder then
        local tool = itemsFolder:FindFirstChild(item.id)
        if tool then
            local clone = tool:Clone()
            clone.Parent = player.Backpack
            return true
        end
    end

    -- Fallback: cria uma ferramenta genérica com damage configurado
    local tool = Instance.new("Tool")
    tool.Name         = item.name
    tool.ToolTip      = item.description
    tool.RequiresHandle = true

    local handle = Instance.new("Part")
    handle.Name          = "Handle"
    handle.Size          = Vector3.new(0.3, 2, 0.3)
    handle.BrickColor    = BrickColor.new("Bright yellow")
    handle.Material      = Enum.Material.SmoothPlastic
    handle.Parent        = tool

    -- Valor de dano armazenado na ferramenta
    local dmgValue = Instance.new("NumberValue")
    dmgValue.Name  = "Damage"
    dmgValue.Value = item.damage or 25
    dmgValue.Parent = tool

    -- Script de ataque básico embutido na ferramenta
    local script = Instance.new("LocalScript")
    script.Name   = "AttackScript"
    -- O script real é carregado pelo cliente; aqui só marca o damage
    script.Parent = tool

    tool.Parent = player.Backpack
    return true
end

local function deliverBoost(player, item)
    local char = player.Character
    if not char then return false end

    local uid    = player.UserId
    local boostId = item.id

    if not activeBoosted[uid] then activeBoosted[uid] = {} end
    if activeBoosted[uid][boostId] then return false end  -- já ativo, não duplica

    activeBoosted[uid][boostId] = true

    if boostId == "boost_speed" then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed += 8
            task.delay(item.duration, function()
                activeBoosted[uid][boostId] = nil
                if hum and hum.Parent then hum.WalkSpeed -= 8 end
            end)
        end

    elseif boostId == "boost_shield" then
        local profile = player:FindFirstChild("PlayerProfile")
        if profile then
            local shield = Instance.new("BoolValue")
            shield.Name   = "Shield"
            shield.Value  = true
            shield.Parent = profile
            task.delay(item.duration, function()
                activeBoosted[uid][boostId] = nil
                if shield and shield.Parent then shield:Destroy() end
            end)
        end

    elseif boostId == "boost_magnet" then
        local profile = player:FindFirstChild("PlayerProfile")
        if profile then
            local magnet = Instance.new("NumberValue")
            magnet.Name   = "CoinMultiplier"
            magnet.Value  = 3
            magnet.Parent = profile
            task.delay(item.duration, function()
                activeBoosted[uid][boostId] = nil
                if magnet and magnet.Parent then magnet:Destroy() end
            end)
        end
    end

    return true
end

local function deliverCosmetic(player, item)
    -- Armazena cosmético ativo no perfil
    local profile = player:FindFirstChild("PlayerProfile")
    if profile then
        local cosmetics = profile:FindFirstChild("Cosmetics")
        if not cosmetics then
            cosmetics      = Instance.new("Folder")
            cosmetics.Name = "Cosmetics"
            cosmetics.Parent = profile
        end
        local v = Instance.new("StringValue")
        v.Name   = item.id
        v.Value  = item.id
        v.Parent = cosmetics

        -- Notifica cliente para aplicar efeito visual
        getRemotes().ApplyCosmetic:FireClient(player, item.id)
        return true
    end
    return false
end

-- ============================================================
-- Handler de compra (chamado pelo cliente via RemoteFunction)
-- ============================================================

local function onBuyItem(player, itemId)
    local item = getItemById(itemId)
    if not item then
        return false, "Item não encontrado."
    end

    -- Nathan não paga
    local price = isCreator(player) and 0 or item.price

    if getCoins(player) < price then
        return false, "Coins insuficientes."
    end

    local delivered = false
    if item.category == "weapon" then
        delivered = deliverWeapon(player, item)
    elseif item.category == "boost" then
        delivered = deliverBoost(player, item)
    elseif item.category == "cosmetic" then
        delivered = deliverCosmetic(player, item)
    end

    if delivered then
        addCoins(player, -price)
        getRemotes().ShopResult:FireClient(player, true, "Comprado: " .. item.name)
        return true, "OK"
    end

    return false, "Não foi possível entregar o item."
end

-- ============================================================
-- Handler de desbloqueio de andar (RemoteFunction)
-- ============================================================

local function onUnlockFloor(player, floorId)
    local floorData
    for _, f in GameConfig.FLOORS do
        if f.id == floorId then floorData = f; break end
    end
    if not floorData then return false, "Andar inválido." end

    local price = isCreator(player) and 0 or floorData.unlockPrice
    if getCoins(player) < price then
        return false, "Coins insuficientes."
    end

    local profile = player:FindFirstChild("PlayerProfile")
    if not profile then return false, "Perfil não carregado." end

    local unlocked = profile:FindFirstChild("UnlockedFloors")
    if not unlocked then
        unlocked      = Instance.new("Folder")
        unlocked.Name = "UnlockedFloors"
        unlocked.Parent = profile
    end

    if unlocked:FindFirstChild("Floor_" .. floorId) then
        return false, "Andar já desbloqueado."
    end

    local v = Instance.new("BoolValue")
    v.Name   = "Floor_" .. floorId
    v.Value  = true
    v.Parent = unlocked

    addCoins(player, -price)
    getRemotes().FloorUnlocked:FireClient(player, floorId)
    return true, "Andar " .. floorData.name .. " desbloqueado!"
end

-- ============================================================
-- Conecta RemoteFunctions quando Remotes estiver pronto
-- ============================================================

task.spawn(function()
    local remotes = getRemotes()

    -- Aguarda criação das remotas pelo Remotes.server.lua
    local buyFunc     = remotes:WaitForChild("BuyItem", 10)
    local unlockFunc  = remotes:WaitForChild("UnlockFloor", 10)

    if buyFunc    then buyFunc.OnServerInvoke    = onBuyItem    end
    if unlockFunc then unlockFunc.OnServerInvoke = onUnlockFloor end
end)

print("[ShopService] Inicializado.")
