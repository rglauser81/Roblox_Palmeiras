-- SoundController.lua
-- Gerencia sons do cliente (música, efeitos sonoros)

local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SoundController = {}

local sounds = {}

function SoundController.init()
    local soundFolder = ReplicatedStorage:WaitForChild("Sounds")
    for _, sound in soundFolder:GetChildren() do
        if sound:IsA("Sound") then
            sounds[sound.Name] = sound
        end
    end
end

function SoundController.play(name, parent)
    local sound = sounds[name]
    if not sound then
        warn("[SoundController] Som não encontrado:", name)
        return
    end
    local clone = sound:Clone()
    clone.Parent = parent or game:GetService("SoundService")
    clone:Play()
    clone.Ended:Connect(function()
        clone:Destroy()
    end)
end

function SoundController.playRoundStart()
    SoundController.play("RoundStart")
end

function SoundController.playRoundEnd()
    SoundController.play("RoundEnd")
end

function SoundController.playKill()
    SoundController.play("KillSfx")
end

return SoundController
