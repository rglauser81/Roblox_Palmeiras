#!/bin/bash
# deploy.sh — Compila e prepara para deploy no Roblox
# Uso: ./scripts/deploy.sh
#
# Para publicar no Roblox, o upload é feito pelo Studio:
#   File → Publish to Roblox → escolha a experiência → Publish

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT="$PROJECT_DIR/Place1.rbxl"

echo "📦 Build para deploy..."
rojo build "$PROJECT_DIR/default.project.json" --output "$OUTPUT"
echo "✅ Arquivo gerado: $OUTPUT"
echo ""
echo "📤 Para publicar no Roblox:"
echo "   1. Abra '$OUTPUT' no Roblox Studio"
echo "   2. File → Publish to Roblox"
echo "   3. Selecione sua experiência (ou crie uma nova)"
echo "   4. Clique 'Publish'"
echo ""
echo "🧪 Para testar antes de publicar:"
echo "   1. Abra '$OUTPUT' no Roblox Studio"
echo "   2. Home → Play (F5) para teste solo"
echo "   3. Test → Start para teste multiplayer local"
