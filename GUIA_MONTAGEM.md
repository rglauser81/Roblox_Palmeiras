# 🏟️ Guia de Montagem — Allianz Brainrot Arena

## Pré-requisitos
- Roblox Studio aberto
- Projeto novo com **Baseplate** (ou usar o `Place1.rbxl`)
- **DataStore habilitado**: `Game Settings > Security > Enable Studio Access to API Services ✅`

---

## Estrutura de pastas no Explorer (crie antes de colar os scripts)

```
DataModel
├── ServerScriptService
│   ├── Remotes          ← Script (server) — DEVE SER O PRIMEIRO
│   ├── GameManager      ← Script (server)
│   ├── NathanService    ← Script (server)
│   ├── ArenaBuilder     ← Script (server)
│   ├── DataService      ← Script (server)
│   ├── ShopService      ← Script (server)
│   ├── CombatService    ← Script (server)
│   ├── RoundManager     ← ModuleScript
│   └── MobSpawner       ← ModuleScript
│
├── ReplicatedStorage
│   └── Shared           ← Folder
│       ├── GameConfig   ← ModuleScript  ⭐ edite o UserId do Nathan aqui
│       ├── Config       ← ModuleScript
│       └── MobData      ← ModuleScript
│
└── StarterPlayer
    └── StarterPlayerScripts
        ├── MainClient     ← LocalScript
        ├── ArenaHud       ← LocalScript
        ├── ShopClient     ← LocalScript
        ├── HudController  ← ModuleScript
        ├── SoundController← ModuleScript
        └── EffectsController ← ModuleScript
```

---

## Tabela de arquivos → onde colocar

| Arquivo | Tipo | Onde no Explorer |
|---------|------|-----------------|
| `Remotes.server.lua` | Script | ServerScriptService > **Remotes** |
| `GameManager.server.lua` | Script | ServerScriptService > **GameManager** |
| `NathanService.server.lua` | Script | ServerScriptService > **NathanService** |
| `ArenaBuilder.server.lua` | Script | ServerScriptService > **ArenaBuilder** |
| `DataService.server.lua` | Script | ServerScriptService > **DataService** |
| `ShopService.server.lua` | Script | ServerScriptService > **ShopService** |
| `CombatService.server.lua` | Script | ServerScriptService > **CombatService** |
| `RoundManager.lua` | ModuleScript | ServerScriptService > **RoundManager** |
| `MobSpawner.lua` | ModuleScript | ServerScriptService > **MobSpawner** |
| `GameConfig.lua` | ModuleScript | ReplicatedStorage > Shared > **GameConfig** |
| `Config.lua` | ModuleScript | ReplicatedStorage > Shared > **Config** |
| `MobData.lua` | ModuleScript | ReplicatedStorage > Shared > **MobData** |
| `MainClient.client.lua` | LocalScript | StarterPlayer > StarterPlayerScripts > **MainClient** |
| `ArenaHud.client.lua` | LocalScript | StarterPlayer > StarterPlayerScripts > **ArenaHud** |
| `ShopClient.client.lua` | LocalScript | StarterPlayer > StarterPlayerScripts > **ShopClient** |
| `HudController.lua` | ModuleScript | StarterPlayer > StarterPlayerScripts > **HudController** |
| `SoundController.lua` | ModuleScript | StarterPlayer > StarterPlayerScripts > **SoundController** |
| `EffectsController.lua` | ModuleScript | StarterPlayer > StarterPlayerScripts > **EffectsController** |

---

## ⭐ Configurar o Nathan

Abra `ReplicatedStorage > Shared > GameConfig` e edite:

```lua
GameConfig.NATHAN_USER_ID = 0  -- ← coloque o UserId real do Nathan aqui
```

> **Como encontrar o UserId:** entre no Roblox, vá no perfil do Nathan,
> o número na URL é o UserId. Ex: `roblox.com/users/123456789/profile`

Se deixar `0`, o **primeiro jogador a entrar** recebe os poderes (modo teste).

---

## Checklist de teste (Play no Studio)

- [ ] Arena construída automaticamente (4 andares visíveis)
- [ ] Loja dourada aparece no Andar 1 (canto esquerdo)
- [ ] Rodada 1 inicia após alguns segundos
- [ ] Mobs aparecem nos spawn points
- [ ] HUD mostra rodada, andar, kills e coins
- [ ] Pisar no pad amarelo sobe de andar
- [ ] Entrar na loja abre a GUI com as 3 abas
- [ ] Nathan (ou primeiro jogador) tem aura dourada e tag
- [ ] Comandos `/chuva`, `/divino`, `/boost`, `/evento` funcionam no chat
- [ ] Dados salvam (teste: sair e entrar — kills/coins persistem)

---

## Próximos passos sugeridos

1. **Modelos dos mobs** → crie modelos 3D em `ReplicatedStorage > Mobs`
   - Nome deve ser exatamente igual ao campo `name` em `MobSpawner.lua`
   - Ex: `Tralalero`, `BombardinoCoccodrillo`, etc.

2. **Ferramentas na loja** → crie Tools em `ReplicatedStorage > Items`
   - Nome = `id` do item em `GameConfig.SHOP_ITEMS` (ex: `sword_basic`)

3. **Sons** → crie Sounds em `ReplicatedStorage > Sounds`
   - Nomes: `RoundStart`, `RoundEnd`, `KillSfx`

4. **GUI do Nathan** → o HUD já aparece; para personalizar a loja dourada
   edite `ArenaBuilder.server.lua` > função `buildNathanShop`
