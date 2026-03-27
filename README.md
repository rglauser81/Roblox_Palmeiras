# Brainrot Game — Roblox

Jogo de ondas (wave survival) com mobs temáticos do universo **brainrot italiano/internet**.

## Estrutura do Projeto

```
Roblox_Palmeiras/
├── default.project.json          # Configuração Rojo
├── Place1.rbxl                   # Arquivo do Roblox Studio
└── src/
    ├── ServerScriptService/      # Scripts exclusivos do servidor
    │   ├── GameManager.server.lua    # Inicializa o jogo e jogadores
    │   ├── Remotes.server.lua        # Cria todos os RemoteEvents
    │   ├── RoundManager.lua          # Controla fases/rodadas
    │   ├── MobSpawner.lua            # Spawna e gerencia mobs
    │   └── DataService.server.lua    # Salva/carrega dados (DataStore)
    │
    ├── ReplicatedStorage/        # Recursos compartilhados (server + client)
    │   └── Shared/
    │       ├── Config.lua            # Todas as configurações do jogo
    │       └── MobData.lua           # Tabela central de dados dos mobs
    │
    └── StarterPlayer/
        ├── StarterPlayerScripts/  # Scripts do cliente
        │   ├── MainClient.client.lua    # Entrada do cliente
        │   ├── HudController.lua        # Gerencia UI/HUD
        │   ├── SoundController.lua      # Sons e música
        │   └── EffectsController.lua    # Efeitos visuais
        └── StarterCharacterScripts/  # Scripts do personagem
```

## Mobs Disponíveis

| Mob | Raridade | HP Base | Velocidade |
|-----|----------|---------|------------|
| Tralalero Tralala | Comum | 100 | 16 |
| Bombardino Coccodrillo | Incomum | 200 | 12 |
| Tung Tung Tung Sahur | Incomum | 150 | 18 |
| Cappuccino Assassino | Raro | 400 | 10 |
| Lirili Larila | Épico | 800 | 8 |
| Brio Branta Supremo | Lendário (Boss) | 2000 | 6 |

## Setup com Rojo

1. Instale o [Rojo](https://rojo.space/)
2. Instale o plugin Rojo no Roblox Studio
3. Execute `rojo serve` na pasta do projeto
4. Conecte pelo plugin no Studio

## Configurações de Balanceamento

Edite `src/ReplicatedStorage/Shared/Config.lua` para ajustar:
- `INTERMISSION_TIME` — tempo entre rodadas
- `BASE_MOBS_PER_WAVE` — mobs na primeira onda
- `MOBS_INCREMENT_PER_ROUND` — quantos mobs a mais por rodada
- `HP_SCALE_PER_ROUND` — multiplicador de HP por rodada
