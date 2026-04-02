#!/bin/bash
set -e

APP_NAME="nodeguard"
INSTALL_DIR="$HOME/bin"
DOWNLOAD_URL="https://tusaas-bucket.s3.amazonaws.com/nodeguard/nodeguard"
LAMBDA_API_URL="https://kzpqkztu7f.execute-api.us-east-1.amazonaws.com/generate-api-key"

echo "🚀 Instalando $APP_NAME..."
echo ""

# -----------------------------
# Asegurar ~/bin en PATH
# -----------------------------
mkdir -p "$HOME/bin"
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
    export PATH="$HOME/bin:$PATH"
    echo 'export PATH=$HOME/bin:$PATH' >> "$HOME/.bashrc"
fi

# -----------------------------
# Detectar sudo usable
# -----------------------------
HAS_SUDO=false
if command -v sudo &> /dev/null && sudo -n true 2>/dev/null; then
    HAS_SUDO=true
fi

# -----------------------------
# Validar jq
# -----------------------------
if ! command -v jq &> /dev/null; then
    echo "⚠️ jq no está instalado. Intentando instalar..."
    # 1. Homebrew (mejor opción)
    if command -v brew &> /dev/null; then
        echo "🍺 Instalando jq con Homebrew..."
        brew install jq
    # 2. apt-get con sudo
    elif command -v apt-get &> /dev/null && [ "$HAS_SUDO" = true ]; then
        echo "📦 Instalando jq con apt-get..."
        sudo apt-get update && sudo apt-get install -y jq
    # 3. yum con sudo
    elif command -v yum &> /dev/null && [ "$HAS_SUDO" = true ]; then
        echo "📦 Instalando jq con yum..."
        sudo yum install -y jq
    # 4. fallback local (siempre funciona)
    else
        echo "📦 Instalando jq localmente en ~/bin..."
        curl -L https://github.com/jqlang/jq/releases/latest/download/jq-linux-amd64 -o "$HOME/bin/jq"
        chmod +x "$HOME/bin/jq"
    fi
fi

# Validación final
if ! command -v jq &> /dev/null; then
    echo "❌ jq no pudo instalarse"
    exit 1
fi

echo "✅ jq disponible"
echo ""

# -----------------------------
# Client ID
# -----------------------------
CLIENT_ID=${1:-""}

if [ -z "$CLIENT_ID" ]; then
    read -p "Ingresa tu Client ID: " CLIENT_ID
fi

if [ -z "$CLIENT_ID" ]; then
    echo "❌ Debes ingresar un Client ID"
    exit 1
fi

# -----------------------------
# Generar API_KEY
# -----------------------------
echo "🔑 Generando API_KEY automáticamente..."

RESPONSE=$(curl -s -X POST "$LAMBDA_API_URL" \
    -H "Content-Type: application/json" \
    -d "{\"client_id\": \"$CLIENT_ID\"}")

API_KEY=$(echo "$RESPONSE" | jq -r '.api_key // empty')

if [ -z "$API_KEY" ]; then
    API_KEY=$(echo "$RESPONSE" | jq -r '.body | fromjson | .api_key // empty')
fi

if [ -z "$API_KEY" ]; then
    echo "❌ Error: No se pudo generar API_KEY"
    echo "Respuesta del servidor: $RESPONSE"
    exit 1
fi

echo "✅ API_KEY generada correctamente"
echo ""

# -----------------------------
# Clusters
# -----------------------------
read -p "Ingresa clusters (Nombre:Contexto, separados por coma) o Enter para default: " CLUSTERS_INPUT

# -----------------------------
# Descargar binario
# -----------------------------
echo "📥 Descargando $APP_NAME..."

if ! curl -f -L "$DOWNLOAD_URL" -o "$INSTALL_DIR/$APP_NAME"; then
    echo "❌ Error descargando $APP_NAME"
    exit 1
fi

chmod +x "$INSTALL_DIR/$APP_NAME"

# -----------------------------
# Configuración
# -----------------------------
CONFIG_FILE="$HOME/.nodeguard.env"

echo "API_KEY=$API_KEY" > "$CONFIG_FILE"
echo "API_URL=https://jflxecc412.execute-api.us-east-1.amazonaws.com/prod" >> "$CONFIG_FILE"
echo "CHECK_INTERVAL=300" >> "$CONFIG_FILE"

if [ -n "$CLUSTERS_INPUT" ]; then
    echo "CLUSTERS=$CLUSTERS_INPUT" >> "$CONFIG_FILE"
else
    echo "CLUSTERS=BCBot:BCBot-PRO,HubCanales:BCMobile-HubCanales-PRO,IA:IA-PRO" >> "$CONFIG_FILE"
fi

chmod 600 "$CONFIG_FILE"

# -----------------------------
# Auto source
# -----------------------------
if ! grep -q ".nodeguard.env" "$HOME/.bashrc"; then
    echo "source $CONFIG_FILE" >> "$HOME/.bashrc"
fi

# -----------------------------
# Final
# -----------------------------
echo ""
echo "🎉 Instalación completada"
echo ""
echo "👉 Ejecuta:"
echo "source $CONFIG_FILE"
echo "$APP_NAME"
echo ""
echo "✅ NodeGuard listo 🚀"
