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
    CappuccinoAssassino = {
        displayName = "Cappuccino Assassino",
        rarity = "raro",
        baseHp = 400,
        baseDamage = 35,
        speed = 10,
        coinReward = 60,
        description = "Perigoso. Não tome café antes de enfrentá-lo.",
    },
    LiriliLarila = {
        displayName = "Lirili Larila",
        rarity = "épico",
        baseHp = 800,
        baseDamage = 50,
        speed = 8,
        coinReward = 120,
        description = "O chefão dos memes. Alta vida, alto dano.",
    },
    BrioBranta = {
        displayName = "Brio Branta Supremo",
        rarity = "lendário",
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
