# 🏟️ ALLIANZ BRAINROT ARENA — Guia de Montagem (40 min)

## Visão Geral

Um estádio de 3 andares inspirado no Allianz Parque com:
- **8 raridades** de brainrots (Comum → Divino)
- **Desafios de matemática/lógica** que desbloqueiam áreas
- **Mutações**: Ouro, Céu Alviverde (anjinhos do Palmeiras), Diamante
- **Celestial** a cada 4 min, **Divino** a cada 1 hora
- **Nathan** como criador com poderes de admin

---

## PASSO 1 — Criar Projeto (1 min)

1. Abra o **Roblox Studio**
2. Clique em **New** > **Baseplate**
3. **Delete** a Baseplate padrão no Explorer (não vamos usá-la)

---

## PASSO 2 — Estrutura de Pastas (2 min)

No **Explorer**, crie esta estrutura:

```
ReplicatedStorage
  └── Modules (Folder)
       └── GameConfig (ModuleScript)  ← Script 01

ServerScriptService
  ├── PlayerDataManager (Script)      ← Script 02
  ├── DesafioSystem (Script)          ← Script 03
  ├── BrainrotSpawner (Script)        ← Script 04
  ├── NathanSystem (Script)           ← Script 05
  └── StadiumBuilder (Script)         ← Script 07

StarterPlayer
  └── StarterPlayerScripts
       └── ClientUI (LocalScript)     ← Script 06
```

### Como criar cada item:
- **Folder**: Clique direito no pai > Insert Object > Folder > Renomear
- **ModuleScript**: Clique direito > Insert Object > ModuleScript > Renomear
- **Script**: Clique direito > Insert Object > Script > Renomear
- **LocalScript**: Clique direito > Insert Object > LocalScript > Renomear

---

## PASSO 3 — Colar os Scripts (15 min)

Abra cada script criado acima (duplo clique) e cole o conteúdo:

| Arquivo | Onde colar | Tipo |
|---------|-----------|------|
| `01_GameConfig.lua` | ReplicatedStorage > Modules > **GameConfig** | ModuleScript |
| `02_PlayerDataManager.lua` | ServerScriptService > **PlayerDataManager** | Script |
| `03_DesafioSystem.lua` | ServerScriptService > **DesafioSystem** | Script |
| `04_BrainrotSpawner.lua` | ServerScriptService > **BrainrotSpawner** | Script |
| `05_NathanSystem.lua` | ServerScriptService > **NathanSystem** | Script |
| `06_ClientUI.lua` | StarterPlayer > StarterPlayerScripts > **ClientUI** | LocalScript |
| `07_StadiumBuilder.lua` | ServerScriptService > **StadiumBuilder** | Script |

**IMPORTANTE**: Ao colar, delete o código padrão (`print("Hello world!")`) que vem no script antes de colar.

---

## PASSO 4 — Configurar o Nathan (2 min)

1. Descubra o **UserId** do Nathan no Roblox:
   - Acesse `https://www.roblox.com/users/NUMERO/profile`
   - O número na URL é o UserId
2. Abra `01_GameConfig.lua` (GameConfig)
3. Na seção `Config.Nathan`, troque `userId = 0` pelo número real
4. Se deixar `0`, o primeiro jogador a entrar será tratado como Nathan (bom pra testar)

---

## PASSO 5 — Habilitar HTTP e DataStore (1 min)

1. **Game Settings** (aba Home > Game Settings)
2. Aba **Security**:
   - ✅ Enable Studio Access to API Services
   - ✅ Allow HTTP Requests
3. Clique **Save**

---

## PASSO 6 — Testar (5 min)

1. Clique em **▶ Play** na aba Home
2. Verifique no **Output** (View > Output) se não há erros em vermelho
3. Teste:
   - [ ] HUD aparece (dinheiro, slots, renda)
   - [ ] Timers de Celestial/Divino no canto
   - [ ] Portais coloridos no campo (andar 2)
   - [ ] Toque num portal → popup de desafio
   - [ ] Resposta correta → barreira abre
   - [ ] Brainrots comuns spawnam e podem ser coletados
   - [ ] Placar no leaderboard funciona

---

## PASSO 7 — Publicar (2 min)

1. **File** > **Publish to Roblox As...**
2. Nome: `Allianz Brainrot Arena`
3. Descrição:
```
🏟️ Estádio de 3 andares inspirado no Allianz Parque!
🧠 Resolva desafios de matemática e lógica
🦎 Colete brainrots de 8 raridades
✨ Mutações: Ouro, Céu Alviverde (anjinhos!), Diamante
🌟 Celestial a cada 4 min | 👑 Divino a cada 1 hora
⚡ Criado por Nathan
```
4. Gênero: **All** ou **Adventure**
5. Clique em **Create**

---

## Mapa dos 3 Andares

### Andar 1 — Bilheteria (y=0)
- Entrada do jogador (spawn point)
- 4 guichês de bilheteria
- Loja do Nathan (dourada, neon)
- NPC do Nathan interativo
- Rampa/escada para o Andar 2

### Andar 2 — Campo de Desafios (y=15)
- Gramado verde com linhas de campo
- 7 portais coloridos (um por raridade a desbloquear)
- Barreiras de ForceField bloqueando áreas
- Zonas de spawn de brainrots por raridade
- Escada para o Andar 3

### Andar 3 — Arena Brainrot (y=35)
- Piso metálico (DiamondPlate)
- 8 bases para jogadores armazenarem brainrots
- Altar Divino central (onde spawna o Porco Sagrado)
- Refletores com SpotLight (jogo noturno)
- Pilares estilo Allianz

---

## Comandos do Nathan (Chat)

| Comando | Efeito |
|---------|--------|
| `/chuva` | Spawna 10 brainrots caindo do céu |
| `/divino` | Invoca o Porco Sagrado Dourado |
| `/boost` | Dá $10.000 para todos os jogadores |
| `/evento` | Ativa evento de renda 2x |

---

## Sistema de Raridades

| Raridade | Spawn | Renda/s | Cor |
|----------|-------|---------|-----|
| Comum | 5s | 8-15 | Cinza |
| Raro | 15s | 45-55 | Azul |
| Épico | 30s | 150-200 | Roxo |
| Lendário | 1 min | 500-600 | Laranja |
| Mítico | 2 min | 2000-2500 | Rosa |
| Secreto | 3 min | 8000-10000 | Preto |
| Celestial | **4 min** | 50000-65000 | Azul claro |
| Divino | **1 hora** | 500000 | Dourado |

---

## Mutações

| Mutação | Chance | Multiplicador | Visual |
|---------|--------|---------------|--------|
| Ouro | 5% | 3x renda | Brilho dourado + PointLight |
| Céu Alviverde | 2% | 5x renda | 3 anjinhos brancos orbitando |
| Diamante | 0.5% | 10x renda | Cristais + Glass + Sparkles |

---

## Desafios para Desbloquear Áreas

| Nível | Desbloqueia | Exemplo |
|-------|------------|---------|
| 1 | Raro | "Quanto é 7 × 8?" |
| 2 | Épico | "Sequência: 2, 6, 18, 54, ???" |
| 3 | Lendário | "Raiz quadrada de 144?" |
| 4 | Mítico | "P+A+L+M+E+I+R+A+S = ???" |
| 5 | Secreto | "2^10 = ???" |
| 6 | Celestial | "Fibonacci: 1,1,2,3,5,8,13,21,???" |
| 7 | Divino | "Títulos brasileiros do Palmeiras?" |

---

## Solução de Problemas

**Erro: "GameConfig is not a valid member"**
→ Verifique se GameConfig é um **ModuleScript** (não Script normal)

**Erro: "attempt to index nil"**
→ Algum objeto ainda não carregou. O `WaitForChild` deveria resolver, mas verifique os nomes.

**Brainrots não spawnam**
→ Verifique se o script `04_BrainrotSpawner` está no ServerScriptService

**UI não aparece**
→ `06_ClientUI` deve ser **LocalScript** em StarterPlayerScripts

**DataStore não salva**
→ Habilite "Enable Studio Access to API Services" em Game Settings > Security
