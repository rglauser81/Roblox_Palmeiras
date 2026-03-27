-- RoundManager.lua
-- Controla as fases/rodadas do jogo
-- Entre rodadas, roda o Desafio de Gol ⚽

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)
local MobSpawner = require(script.Parent.MobSpawner)
local GoalChallenge = require(script.Parent.GoalChallenge)

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

        -- Intermission: Desafio de Gol!
        -- O desafio dura GOAL_CHALLENGE_DURATION e depois espera o restante do intermission
        local challengeDuration = GameConfig.FOOTBALL.GOAL_CHALLENGE_DURATION
        local remaining = GameConfig.INTERMISSION_TIME - challengeDuration

        GoalChallenge.start(currentRound, challengeDuration)

        -- Se o intermission total é maior que o desafio, espera o restante
        if remaining > 0 then
            task.wait(remaining)
        end
    end
end

function RoundManager.getCurrentRound()
    return currentRound
end

function RoundManager.isActive()
    return roundActive
end

return RoundManager
