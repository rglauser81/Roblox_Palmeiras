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
