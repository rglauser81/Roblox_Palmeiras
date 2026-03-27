-- RoundManager.lua
-- Controla as fases/rodadas do jogo

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local MobSpawner = require(script.Parent.MobSpawner)

local Remotes = ReplicatedStorage.Remotes

local RoundManager = {}

local currentRound = 0
local roundActive = false

function RoundManager.start()
    while true do
        currentRound += 1
        roundActive = true

        print("[RoundManager] Iniciando rodada", currentRound)
        Remotes.RoundStarted:FireAllClients(currentRound)

        -- Spawna mobs de acordo com a rodada
        MobSpawner.spawnWave(currentRound)

        -- Aguarda o fim da onda
        MobSpawner.waitForWaveEnd()

        roundActive = false
        Remotes.RoundEnded:FireAllClients(currentRound)
        print("[RoundManager] Rodada", currentRound, "concluída!")

        task.wait(GameConfig.INTERMISSION_TIME)
    end
end

function RoundManager.getCurrentRound()
    return currentRound
end

function RoundManager.isActive()
    return roundActive
end

return RoundManager
