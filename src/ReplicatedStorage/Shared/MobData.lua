-- MobData.lua
-- Tabela central com todos os dados dos mobs de brainrot

local MobData = {}

-- Raridade: "comum", "incomum", "raro", "épico", "lendário"
MobData.mobs = {
    Tralalero = {
        displayName = "Tralalero Tralala",
        rarity = "comum",
        baseHp = 100,
        baseDamage = 10,
        speed = 16,
        coinReward = 10,
        description = "O clássico. Fraco, mas aparece em grande número.",
    },
    BonecaAmbalabu = {
        displayName = "Boneca Ambalabu",
        rarity = "comum",
        baseHp = 80,
        baseDamage = 8,
        speed = 18,
        coinReward = 8,
        description = "A bonequinha que danca sem parar. Rapida mas fragil.",
    },
    FrigoCamelo = {
        displayName = "Frigo Camelo",
        rarity = "comum",
        baseHp = 120,
        baseDamage = 12,
        speed = 14,
        coinReward = 12,
        description = "Um camelo gelado. Anda devagar, aguenta mais.",
    },
    SalminoPinguino = {
        displayName = "Salmino Pinguino",
        rarity = "comum",
        baseHp = 90,
        baseDamage = 9,
        speed = 20,
        coinReward = 10,
        description = "O pinguim mais rapido do brainrot. Escorregadio!",
    },
    BombardinoCoccodrillo = {
        displayName = "Bombardino Coccodrillo",
        rarity = "incomum",
        baseHp = 200,
        baseDamage = 20,
        speed = 12,
        coinReward = 25,
        description = "Mais resistente. Cuidado com a mordida.",
    },
    TungTungSahur = {
        displayName = "Tung Tung Tung Sahur",
        rarity = "incomum",
        baseHp = 150,
        baseDamage = 15,
        speed = 18,
        coinReward = 20,
        description = "Rápido como os sons que o inspiraram.",
    },
    ChimpanziniBananini = {
        displayName = "Chimpanzini Bananini",
        rarity = "incomum",
        baseHp = 180,
        baseDamage = 18,
        speed = 16,
        coinReward = 22,
        description = "Macaco maluco que joga bananas nos jogadores.",
    },
    BallerinaCappuccina = {
        displayName = "Ballerina Cappuccina",
        rarity = "incomum",
        baseHp = 160,
        baseDamage = 22,
        speed = 14,
        coinReward = 28,
        description = "Danca de forma hipnotizante enquanto ataca.",
    },
    CappuccinoAssassino = {
        displayName = "Cappuccino Assassino",
        rarity = "raro",
        baseHp = 400,
        baseDamage = 35,
        speed = 10,
        coinReward = 60,
        description = "Perigoso. Não tome café antes de enfrentá-lo.",
    },
    GlorboFruttodrillo = {
        displayName = "Glorbo Fruttodrillo",
        rarity = "raro",
        baseHp = 350,
        baseDamage = 40,
        speed = 11,
        coinReward = 55,
        description = "Crocodilo frutado. Morde com gosto de manga.",
    },
    LaVacaSaturno = {
        displayName = "La Vaca Saturno Saturno",
        rarity = "raro",
        baseHp = 500,
        baseDamage = 30,
        speed = 8,
        coinReward = 70,
        description = "A vaca espacial. Tanque lento mas muita vida.",
    },
    LiriliLarila = {
        displayName = "Lirili Larila",
        rarity = "epico",
        baseHp = 800,
        baseDamage = 50,
        speed = 8,
        coinReward = 120,
        description = "O chefão dos memes. Alta vida, alto dano.",
    },
    TrippiTroppi = {
        displayName = "Trippi Troppi",
        rarity = "epico",
        baseHp = 700,
        baseDamage = 60,
        speed = 10,
        coinReward = 100,
        description = "Imprevisivel! Muda de direcao aleatoriamente.",
    },
    BobritoFrittomisto = {
        displayName = "Bobrito Frittomisto",
        rarity = "epico",
        baseHp = 1000,
        baseDamage = 45,
        speed = 7,
        coinReward = 150,
        description = "Frito por fora, perigoso por dentro. Tanque supremo.",
    },
    BrioBranta = {
        displayName = "Brio Branta Supremo",
        rarity = "lendario",
        baseHp = 2000,
        baseDamage = 100,
        speed = 6,
        coinReward = 500,
        description = "Aparece raramente. Uma verdadeira lenda do brainrot.",
        isBoss = true,
    },

    -- === NOVOS MOBS — Allianz Brainrot Arena ===

    ElefanteMorango = {
        displayName = "Elefante Morango",
        rarity = "raro",
        baseHp = 600,
        baseDamage = 35,
        speed = 9,
        coinReward = 80,
        description = "Um elefante vermelho feito de morangos! Pisada pesada.",
        bodyColor = Color3.fromRGB(220, 40, 40),
        headColor = Color3.fromRGB(255, 80, 80),
    },
    MorangoFilhote = {
        displayName = "Morango Filhote",
        rarity = "comum",
        baseHp = 70,
        baseDamage = 6,
        speed = 22,
        coinReward = 8,
        description = "Filhote de morango. Minusculo mas ultra rapido!",
        bodyColor = Color3.fromRGB(200, 30, 30),
        headColor = Color3.fromRGB(255, 60, 60),
    },
    PorcoDourado = {
        displayName = "Porco Dourado Rei",
        rarity = "lendario",
        baseHp = 3000,
        baseDamage = 120,
        speed = 5,
        coinReward = 800,
        description = "O rei dourado do brainrot! Coroa de ouro, moedas caem quando apanha.",
        isBoss = true,
        bodyColor = Color3.fromRGB(255, 200, 0),
        headColor = Color3.fromRGB(255, 215, 0),
    },
    CrocodiloDourado = {
        displayName = "Crocodilo Dourado",
        rarity = "epico",
        baseHp = 1200,
        baseDamage = 70,
        speed = 7,
        coinReward = 200,
        description = "Crocodilo revestido de ouro. Mordida que vale uma fortuna.",
        bodyColor = Color3.fromRGB(218, 165, 32),
        headColor = Color3.fromRGB(255, 200, 50),
    },
    DinoVerde = {
        displayName = "Dino Verde",
        rarity = "incomum",
        baseHp = 170,
        baseDamage = 16,
        speed = 17,
        coinReward = 24,
        description = "Dinossauro verde do Palmeiras. Amigavel ate morder.",
        bodyColor = Color3.fromRGB(0, 140, 0),
        headColor = Color3.fromRGB(34, 180, 34),
    },
    AnjoBrainrot = {
        displayName = "Anjo Brainrot",
        rarity = "epico",
        baseHp = 900,
        baseDamage = 55,
        speed = 12,
        coinReward = 160,
        description = "Anjo de cabelo verde com asas e aureola. Voa pelo campo!",
        bodyColor = Color3.fromRGB(34, 200, 34),
        headColor = Color3.fromRGB(180, 255, 180),
        hasWings = true,
    },
    AnjoBrainrotMini = {
        displayName = "Anjinho Brainrot",
        rarity = "incomum",
        baseHp = 140,
        baseDamage = 14,
        speed = 20,
        coinReward = 22,
        description = "Mini anjo com asas verdes. Rapido e gracioso.",
        bodyColor = Color3.fromRGB(50, 220, 50),
        headColor = Color3.fromRGB(200, 255, 200),
        hasWings = true,
    },
}

function MobData.get(name)
    return MobData.mobs[name]
end

function MobData.getByRarity(rarity)
    local result = {}
    for name, data in MobData.mobs do
        if data.rarity == rarity then
            table.insert(result, { name = name, data = data })
        end
    end
    return result
end

return MobData
