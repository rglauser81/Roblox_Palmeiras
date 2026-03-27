-- MainClient.client.lua
-- Script principal do cliente: inicializa efeitos e sons
-- HUD é gerenciado por ArenaHud.client.lua (independente)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local SoundController = require(script.Parent.SoundController)
local EffectsController = require(script.Parent.EffectsController)

-- Inicializa controladores
SoundController.init()
EffectsController.init()

-- Ouve início de rodada
Remotes.RoundStarted.OnClientEvent:Connect(function(_round)
    SoundController.playRoundStart()
end)

-- Ouve fim de rodada
Remotes.RoundEnded.OnClientEvent:Connect(function(_round)
    SoundController.playRoundEnd()
end)

-- Ouve kill confirmado pelo servidor
Remotes.MobKilled.OnClientEvent:Connect(function(_mobName, _coins)
    SoundController.playKill()
    EffectsController.spawnKillEffect(localPlayer.Character)
end)
