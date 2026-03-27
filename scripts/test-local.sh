#!/bin/bash
# test-local.sh — Build + abre no Roblox Studio para teste local
# Uso: ./scripts/test-local.sh

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT="$PROJECT_DIR/Place1.rbxl"

echo "🔨 Compilando para teste local..."
rojo build "$PROJECT_DIR/default.project.json" --output "$OUTPUT"
echo "✅ Build concluído: $OUTPUT"
echo ""
echo "🎮 Abrindo no Roblox Studio..."
open "$OUTPUT"
echo ""
echo "📋 No Studio:"
echo "   • F5         → Play (teste solo)"
echo "   • Test → Start → 2 Players → Start  → teste multiplayer"
echo "   • Ctrl+F6    → Parar teste"
