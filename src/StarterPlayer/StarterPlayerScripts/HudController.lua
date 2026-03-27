-- HudController.lua
-- Gerencia todos os elementos de UI do jogador (HUD)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local HudController = {}

local hudGui
local roundLabel
local killFeedFrame
local coinLabel

function HudController.init()
    hudGui = playerGui:WaitForChild("HudGui")
    roundLabel = hudGui:FindFirstChild("RoundLabel", true)
    killFeedFrame = hudGui:FindFirstChild("KillFeed", true)
    coinLabel = hudGui:FindFirstChild("CoinLabel", true)
end

function HudController.setRound(round)
    if roundLabel then
        roundLabel.Text = "Rodada: " .. round
    end
end

function HudController.showNotification(text, color)
    local notif = hudGui:FindFirstChild("Notification", true)
    if not notif then return end

    notif.Text = text
    notif.TextColor3 = color or Color3.new(1, 1, 1)
    notif.Visible = true

    local tween = TweenService:Create(notif, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 1,
    })
    tween:Play()
    tween.Completed:Connect(function()
        notif.TextTransparency = 0
        notif.Visible = false
    end)
end

function HudController.showKillFeed(mobName)
    if not killFeedFrame then return end

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 24)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 80, 80)
    label.Text = "Você eliminou: " .. mobName
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Parent = killFeedFrame

    task.delay(3, function()
        label:Destroy()
    end)
end

function HudController.addCoins(amount)
    if not coinLabel then return end
    local current = tonumber(coinLabel.Text:match("%d+")) or 0
    coinLabel.Text = "Coins: " .. (current + amount)
end

return HudController
