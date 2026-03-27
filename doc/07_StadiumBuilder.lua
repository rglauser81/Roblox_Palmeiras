-- =============================================
-- 07_StadiumBuilder (Script)
-- LOCAL: ServerScriptService > StadiumBuilder
-- Roda uma vez ao iniciar o servidor
-- Constrói o estádio de 3 andares automaticamente
-- =============================================

local function criarPart(props)
    local part = Instance.new("Part")
    part.Anchored = true
    part.Name = props.Name or "Part"
    part.Size = props.Size or Vector3.new(4, 1, 4)
    part.Position = props.Position or Vector3.new(0, 0, 0)
    part.Color = props.Color or Color3.fromRGB(128, 128, 128)
    part.Material = props.Material or Enum.Material.SmoothPlastic
    part.Transparency = props.Transparency or 0
    part.CanCollide = props.CanCollide ~= false
    part.Parent = props.Parent or workspace
    return part
end

local function criarTexto(parent, texto, offset, cor, tamanho)
    local bg = Instance.new("BillboardGui")
    bg.Size = UDim2.new(0, tamanho or 300, 0, 60)
    bg.StudsOffset = offset or Vector3.new(0, 5, 0)
    bg.AlwaysOnTop = false
    bg.Parent = parent

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = texto
    txt.TextColor3 = cor or Color3.new(1, 1, 1)
    txt.TextScaled = true
    txt.Font = Enum.Font.GothamBold
    txt.TextStrokeTransparency = 0
    txt.Parent = bg
    return bg
end

-- ============================
-- PASTA PRINCIPAL
-- ============================
local estadio = Instance.new("Folder")
estadio.Name = "AllianzBrainrotArena"
estadio.Parent = workspace

-- ============================
-- ANDAR 1: BILHETERIA (y=0)
-- ============================
local andar1 = Instance.new("Folder")
andar1.Name = "Andar1_Bilheteria"
andar1.Parent = estadio

-- Chão da bilheteria
criarPart({
    Name = "ChaoBilheteria",
    Size = Vector3.new(220, 2, 160),
    Position = Vector3.new(0, -1, 0),
    Color = Color3.fromRGB(60, 60, 70),
    Material = Enum.Material.Concrete,
    Parent = andar1,
})

-- Paredes externas (estilo arena oval — 4 paredes retas simplificadas)
-- Parede frontal
criarPart({
    Name = "ParedeFrontal",
    Size = Vector3.new(220, 50, 3),
    Position = Vector3.new(0, 25, -81),
    Color = Color3.fromRGB(20, 60, 20), -- verde Palmeiras
    Material = Enum.Material.Concrete,
    Parent = andar1,
})
-- Parede traseira
criarPart({
    Name = "ParedeTraseira",
    Size = Vector3.new(220, 50, 3),
    Position = Vector3.new(0, 25, 81),
    Color = Color3.fromRGB(20, 60, 20),
    Material = Enum.Material.Concrete,
    Parent = andar1,
})
-- Parede esquerda
criarPart({
    Name = "ParedeEsq",
    Size = Vector3.new(3, 50, 160),
    Position = Vector3.new(-111, 25, 0),
    Color = Color3.fromRGB(20, 60, 20),
    Material = Enum.Material.Concrete,
    Parent = andar1,
})
-- Parede direita
criarPart({
    Name = "ParedeDir",
    Size = Vector3.new(3, 50, 160),
    Position = Vector3.new(111, 25, 0),
    Color = Color3.fromRGB(20, 60, 20),
    Material = Enum.Material.Concrete,
    Parent = andar1,
})

-- Bilheterias (balcões)
for i = 1, 4 do
    local balcao = criarPart({
        Name = "Bilheteria" .. i,
        Size = Vector3.new(12, 5, 6),
        Position = Vector3.new(-45 + (i * 25), 2.5, -70),
        Color = Color3.fromRGB(0, 100, 0),
        Material = Enum.Material.SmoothPlastic,
        Parent = andar1,
    })
    criarTexto(balcao, "🎫 Bilheteria " .. i, Vector3.new(0, 5, 0), Color3.fromRGB(255, 215, 0))
end

-- Loja do Nathan
local lojaNathan = criarPart({
    Name = "LojaNathan",
    Size = Vector3.new(20, 8, 12),
    Position = Vector3.new(0, 4, -65),
    Color = Color3.fromRGB(255, 215, 0),
    Material = Enum.Material.Neon,
    Parent = andar1,
})
criarTexto(lojaNathan, "👑 NATHAN'S SHOP 👑", Vector3.new(0, 7, 0), Color3.fromRGB(255, 215, 0), 350)

-- NPC do Nathan (parte visual)
local nathanNPC = criarPart({
    Name = "NathanNPC",
    Size = Vector3.new(3, 6, 2),
    Position = Vector3.new(0, 3, -60),
    Color = Color3.fromRGB(255, 180, 100),
    Material = Enum.Material.SmoothPlastic,
    Parent = andar1,
})
criarTexto(nathanNPC, "⚡ Nathan — Criador ⚡\nToque para interagir", Vector3.new(0, 5, 0), Color3.fromRGB(255, 215, 0), 250)

-- Escada para andar 2
criarPart({
    Name = "EscadaSubida1",
    Size = Vector3.new(10, 1, 40),
    Position = Vector3.new(-100, 7, 0),
    Color = Color3.fromRGB(80, 80, 90),
    Material = Enum.Material.Concrete,
    Parent = andar1,
})
-- Rampa
local rampa1 = criarPart({
    Name = "Rampa1",
    Size = Vector3.new(10, 1, 30),
    Position = Vector3.new(-100, 7.5, 0),
    Color = Color3.fromRGB(90, 90, 100),
    Material = Enum.Material.Concrete,
    Parent = andar1,
})
rampa1.CFrame = CFrame.new(-100, 7.5, 0) * CFrame.Angles(math.rad(-20), 0, 0)

-- Spawn point (bilheteria)
local spawn1 = Instance.new("SpawnLocation")
spawn1.Name = "SpawnBilheteria"
spawn1.Size = Vector3.new(10, 1, 10)
spawn1.Position = Vector3.new(0, 1, -50)
spawn1.Color = Color3.fromRGB(0, 100, 0)
spawn1.Material = Enum.Material.Neon
spawn1.Anchored = true
spawn1.Parent = andar1

criarTexto(spawn1, "🏟️ ALLIANZ BRAINROT ARENA", Vector3.new(0, 8, 0), Color3.fromRGB(0, 200, 0), 400)

-- ============================
-- ANDAR 2: CAMPO DE DESAFIOS (y=15)
-- ============================
local andar2 = Instance.new("Folder")
andar2.Name = "Andar2_CampoDesafios"
andar2.Parent = estadio

-- Piso do campo
criarPart({
    Name = "CampoGramado",
    Size = Vector3.new(200, 1, 120),
    Position = Vector3.new(0, 14.5, 0),
    Color = Color3.fromRGB(0, 128, 0),
    Material = Enum.Material.Grass,
    Parent = andar2,
})

-- Linhas do campo
criarPart({
    Name = "LinhaCentral",
    Size = Vector3.new(0.5, 0.1, 120),
    Position = Vector3.new(0, 15.1, 0),
    Color = Color3.fromRGB(255, 255, 255),
    Material = Enum.Material.SmoothPlastic,
    Parent = andar2,
})

-- Círculo central (cilindro)
local circulo = Instance.new("Part")
circulo.Name = "CirculoCentral"
circulo.Shape = Enum.PartType.Cylinder
circulo.Size = Vector3.new(0.2, 40, 40)
circulo.CFrame = CFrame.new(0, 15.1, 0) * CFrame.Angles(0, 0, math.rad(90))
circulo.Color = Color3.fromRGB(255, 255, 255)
circulo.Material = Enum.Material.SmoothPlastic
circulo.Transparency = 0.7
circulo.Anchored = true
circulo.Parent = andar2

-- Zonas de raridade (placas no chão coloridas)
local cores = {
    {nome="Comum",    cor=Color3.fromRGB(180,180,180), x=-70},
    {nome="Raro",     cor=Color3.fromRGB(30,144,255),  x=-50},
    {nome="Épico",    cor=Color3.fromRGB(163,53,238),  x=-30},
    {nome="Lendário", cor=Color3.fromRGB(255,165,0),   x=-10},
    {nome="Mítico",   cor=Color3.fromRGB(255,0,80),    x=10},
    {nome="Secreto",  cor=Color3.fromRGB(30,30,30),    x=30},
    {nome="Celestial",cor=Color3.fromRGB(135,206,250), x=50},
    {nome="Divino",   cor=Color3.fromRGB(255,215,0),   x=70},
}

for _, z in ipairs(cores) do
    local zona = criarPart({
        Name = "Zona_" .. z.nome,
        Size = Vector3.new(18, 0.3, 50),
        Position = Vector3.new(z.x, 15, 0),
        Color = z.cor,
        Material = Enum.Material.Neon,
        Transparency = 0.6,
        Parent = andar2,
    })
    criarTexto(zona, z.nome, Vector3.new(0, 3, 0), z.cor, 180)
end

-- Plataformas de subida para andar 3
for i = 0, 4 do
    criarPart({
        Name = "Degrau_" .. i,
        Size = Vector3.new(8, 1, 8),
        Position = Vector3.new(95, 15 + (i * 4), -50 + (i * 5)),
        Color = Color3.fromRGB(60, 60, 70),
        Material = Enum.Material.Concrete,
        Parent = andar2,
    })
end

-- ============================
-- ANDAR 3: ARENA BRAINROT (y=35)
-- ============================
local andar3 = Instance.new("Folder")
andar3.Name = "Andar3_ArenaBrainrot"
andar3.Parent = estadio

-- Piso elevado
criarPart({
    Name = "PisoArena",
    Size = Vector3.new(200, 1, 120),
    Position = Vector3.new(0, 34.5, 0),
    Color = Color3.fromRGB(40, 40, 50),
    Material = Enum.Material.DiamondPlate,
    Parent = andar3,
})

-- Bases dos jogadores (onde colocar brainrots)
for i = 1, 8 do
    local base = criarPart({
        Name = "BaseJogador_" .. i,
        Size = Vector3.new(12, 0.5, 12),
        Position = Vector3.new(-80 + (i * 20), 35, 40),
        Color = Color3.fromRGB(0, 80, 0),
        Material = Enum.Material.Neon,
        Transparency = 0.3,
        Parent = andar3,
    })
    criarTexto(base, "📦 Base " .. i, Vector3.new(0, 2, 0), Color3.fromRGB(150, 255, 150), 150)
end

-- Área central — palco do Divino
local palcoDivino = criarPart({
    Name = "PalcoDivino",
    Size = Vector3.new(20, 2, 20),
    Position = Vector3.new(0, 36, 0),
    Color = Color3.fromRGB(255, 215, 0),
    Material = Enum.Material.Neon,
    Transparency = 0.3,
    Parent = andar3,
})
criarTexto(palcoDivino, "👑 ALTAR DIVINO 👑\nO Porco Sagrado aparece aqui", Vector3.new(0, 5, 0), Color3.fromRGB(255, 215, 0), 350)

-- Pilares decorativos (estilo Allianz)
for i = 1, 8 do
    local angulo = (i / 8) * math.pi * 2
    local x = math.cos(angulo) * 90
    local z = math.sin(angulo) * 60
    criarPart({
        Name = "Pilar" .. i,
        Size = Vector3.new(4, 50, 4),
        Position = Vector3.new(x, 25, z),
        Color = Color3.fromRGB(20, 60, 20),
        Material = Enum.Material.Concrete,
        Parent = andar3,
    })
end

-- Iluminação
local refletores = Instance.new("Folder")
refletores.Name = "Refletores"
refletores.Parent = estadio

local posRefletores = {
    Vector3.new(-90, 45, -60),
    Vector3.new(90, 45, -60),
    Vector3.new(-90, 45, 60),
    Vector3.new(90, 45, 60),
}

for i, pos in ipairs(posRefletores) do
    local refletor = criarPart({
        Name = "Refletor" .. i,
        Size = Vector3.new(6, 6, 6),
        Position = pos,
        Color = Color3.fromRGB(255, 255, 200),
        Material = Enum.Material.Neon,
        Parent = refletores,
    })
    local light = Instance.new("SpotLight")
    light.Brightness = 5
    light.Range = 80
    light.Angle = 60
    light.Color = Color3.fromRGB(255, 255, 230)
    light.Face = Enum.NormalId.Bottom
    light.Parent = refletor
end

-- ============================
-- LIGHTING CONFIG
-- ============================
local lighting = game:GetService("Lighting")
lighting.Ambient = Color3.fromRGB(100, 100, 120)
lighting.Brightness = 1.5
lighting.ClockTime = 20 -- Noite (jogo noturno estilo Allianz)
lighting.OutdoorAmbient = Color3.fromRGB(50, 50, 70)
lighting.FogEnd = 1000

-- Bloom (efeito neon bonito)
local bloom = Instance.new("BloomEffect")
bloom.Intensity = 0.5
bloom.Size = 24
bloom.Threshold = 0.8
bloom.Parent = lighting

-- Color correction
local cc = Instance.new("ColorCorrectionEffect")
cc.Saturation = 0.2
cc.Contrast = 0.1
cc.Parent = lighting

print("🏟️ Allianz Brainrot Arena construída com sucesso!")
