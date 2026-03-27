-- EffectsController.lua
-- Efeitos visuais do cliente (partículas, screen shake, etc.)

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local EffectsController = {}

local camera = workspace.CurrentCamera
local killFlashFrame

function EffectsController.init()
    -- Cria o KillFlash programaticamente
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local flashGui = Instance.new("ScreenGui")
    flashGui.Name = "EffectsGui"
    flashGui.ResetOnSpawn = false
    flashGui.IgnoreGuiInset = true
    flashGui.DisplayOrder = 100
    flashGui.Parent = playerGui

    killFlashFrame = Instance.new("Frame")
    killFlashFrame.Name = "KillFlash"
    killFlashFrame.Size = UDim2.new(1, 0, 1, 0)
    killFlashFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    killFlashFrame.BackgroundTransparency = 1
    killFlashFrame.BorderSizePixel = 0
    killFlashFrame.Parent = flashGui
end

-- Trepidação de câmera ao matar um mob
function EffectsController.shakeCamera(intensity, duration)
    intensity = intensity or 0.5
    duration = duration or 0.3

    local startTime = tick()
    local connection
    connection = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        if elapsed >= duration then
            connection:Disconnect()
            return
        end
        local factor = 1 - (elapsed / duration)
        local offset = Vector3.new(
            (math.random() * 2 - 1) * intensity * factor,
            (math.random() * 2 - 1) * intensity * factor,
            0
        )
        camera.CFrame = camera.CFrame * CFrame.new(offset)
    end)
end

-- Efeito de flash branco ao matar
function EffectsController.killFlash()
    if not killFlashFrame then return end
    killFlashFrame.BackgroundTransparency = 0.4
    TweenService:Create(killFlashFrame, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
end

function EffectsController.spawnKillEffect(character)
    if not character then return end
    EffectsController.shakeCamera(0.3, 0.2)
    EffectsController.killFlash()
end

return EffectsController
