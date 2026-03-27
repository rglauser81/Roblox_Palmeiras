#!/bin/bash
# build.sh — Compila o projeto Rojo em um arquivo .rbxl
# Uso: ./scripts/build.sh

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT="$PROJECT_DIR/Place1.rbxl"

echo "🔨 Compilando projeto Rojo..."
echo "   Projeto: $PROJECT_DIR/default.project.json"
echo "   Saída:   $OUTPUT"

rojo build "$PROJECT_DIR/default.project.json" --output "$OUTPUT"

echo "✅ Build concluído: $OUTPUT"
echo ""
echo "Próximos passos:"
echo "  1. Abra $OUTPUT no Roblox Studio"
echo "  2. Ou use './scripts/serve.sh' para sincronizar em tempo real"
