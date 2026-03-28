# Allianz Brainrot Arena — Roblox

Jogo de ondas (wave survival) com mobs temáticos do universo **brainrot italiano/internet** no estádio **Allianz Brainrot Arena** — tema **Palmeiras** (verde e branco).

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
| Boneca Ambalabu | Comum | 80 | 18 |
| Frigo Camelo | Comum | 120 | 14 |
| Salmino Pinguino | Comum | 90 | 20 |
| Morango Filhote | Comum | 70 | 22 |
| Bombardino Coccodrillo | Incomum | 200 | 12 |
| Tung Tung Tung Sahur | Incomum | 150 | 18 |
| Chimpanzini Bananini | Incomum | 180 | 16 |
| Ballerina Cappuccina | Incomum | 160 | 14 |
| Dino Verde | Incomum | 170 | 17 |
| Anjinho Brainrot | Incomum | 140 | 20 |
| Cappuccino Assassino | Raro | 400 | 10 |
| Glorbo Fruttodrillo | Raro | 350 | 11 |
| La Vaca Saturno | Raro | 500 | 8 |
| Elefante Morango | Raro | 600 | 9 |
| Lirili Larila | Épico | 800 | 8 |
| Trippi Troppi | Épico | 700 | 10 |
| Bobrito Frittomisto | Épico | 1000 | 7 |
| Crocodilo Dourado | Épico | 1200 | 7 |
| Anjo Brainrot | Épico | 900 | 12 |
| Brio Branta Supremo | Lendário (Boss) | 2000 | 6 |
| Porco Dourado Rei | Lendário (Boss) | 3000 | 5 |

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
