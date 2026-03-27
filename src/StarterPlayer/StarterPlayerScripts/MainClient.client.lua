-- MainClient.client.lua
-- Script principal do cliente: inicializa HUD, efeitos e listeners de eventos

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local HudController = require(script.Parent.HudController)
local SoundController = require(script.Parent.SoundController)
local EffectsController = require(script.Parent.EffectsController)

-- Inicializa controladores
HudController.init()
SoundController.init()
EffectsController.init()

-- Ouve início de rodada
Remotes.RoundStarted.OnClientEvent:Connect(function(round)
    HudController.setRound(round)
    HudController.showNotification("Rodada " .. round .. " iniciada!", Color3.fromRGB(255, 200, 0))
    SoundController.playRoundStart()
end)

-- Ouve fim de rodada
Remotes.RoundEnded.OnClientEvent:Connect(function(round)
    HudController.showNotification("Rodada " .. round .. " concluída!", Color3.fromRGB(0, 255, 100))
    SoundController.playRoundEnd()
end)

-- Ouve kill confirmado pelo servidor
Remotes.MobKilled.OnClientEvent:Connect(function(mobName, coins)
    HudController.showKillFeed(mobName)
    HudController.addCoins(coins)
    EffectsController.spawnKillEffect(localPlayer.Character)
end)
