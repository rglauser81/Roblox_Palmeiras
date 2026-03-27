-- SoundController.lua
-- Gerencia sons do cliente (música, efeitos sonoros)
-- Funciona mesmo sem a pasta Sounds (apenas dá warn)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SoundController = {}

local sounds = {}
local initialized = false

function SoundController.init()
    local soundFolder = ReplicatedStorage:FindFirstChild("Sounds")
    if not soundFolder then
        warn("[SoundController] Pasta 'Sounds' não encontrada em ReplicatedStorage. Sons desativados.")
        return
    end
    for _, sound in soundFolder:GetChildren() do
        if sound:IsA("Sound") then
            sounds[sound.Name] = sound
        end
    end
    initialized = true
end

function SoundController.play(name, parent)
    if not initialized then return end
    local sound = sounds[name]
    if not sound then return end
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
