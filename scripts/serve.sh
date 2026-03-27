#!/bin/bash
# serve.sh — Inicia o servidor Rojo para sincronizar com Roblox Studio em tempo real
# Uso: ./scripts/serve.sh
#
# No Roblox Studio, instale o plugin Rojo e clique "Connect" para sincronizar.

set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "🚀 Iniciando Rojo serve..."
echo "   Projeto: $PROJECT_DIR/default.project.json"
echo ""
echo "📋 Instruções:"
echo "   1. Abra o Roblox Studio"
echo "   2. Instale o plugin Rojo (Plugins → Manage Plugins → busque 'Rojo')"
echo "   3. Clique no botão 'Rojo' na aba Plugins"
echo "   4. Clique 'Connect' no painel do Rojo"
echo "   5. Edite arquivos no VS Code — o Studio atualiza automaticamente!"
echo ""
echo "   Pressione Ctrl+C para parar o servidor."
echo ""

rojo serve "$PROJECT_DIR/default.project.json"
