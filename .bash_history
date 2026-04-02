ll
aws s3 presign s3://tusaas-bucket/nginstall.sh --profile ecr-uploader --expires-in 3600
cat nodeguard.py
ll
rm nginstall.sh 
touch nginstall.sh
nano nginstall.sh 
aws s3 presign s3://tusaas-bucket/nginstall.sh --profile ecr-uploader
aws s3 s3://tusaas-bucket/nginstall.sh --profile ecr-uploader
aws cp s3://tusaas-bucket/nginstall.sh --profile ecr-uploader
aws s3 cp s3://tusaas-bucket/nginstall.sh . --profile ecr-uploader
ll
rm nginstall.sh 
touch nginstall.sh
nano nginstall.sh 
ll
aws s3 cp nginstall.sh s3://tusaas-bucket/nginstall.sh --profile ecr-uploader
cd dist/
ls
nodeguard 
cd
rm dist/
rmdri dist/
aws s3 cp s3://tusaas-bucket/disk/nodeguard ./nodeguard --profile ecr-uploader
aws s3 cp s3://tusaas-bucket/nodeguard/nodeguard ./nodeguard --profile ecr-uploader
ls
ll
cd ./
ll
ls -la
cd .
ll
ls -lh nodeguard
pwd
cd ./
chmod ./ 731
chmod . 731
chmod +x nodeguard
ll
aws s3 cp s3://tusaas-bucket/nodeguard/nodeguard ./nodeguard --profile ecr-uploader
ll
ls -la
ls -lah
find . -type f -name "nodeguard"
cd ./nodeguard
./nodeguard
chmod +x nodeguard
./nodeguard
cd dist/
ll
ls -la
cd
pyinstaller --onefile nodeguard.py --collect-all requests
cd dist/
ll
cd
rm -rf build dist *.spec
pyinstaller --onefile nodeguard.py --collect-all requests
cd dist/
ll
cd
aws s3 cp dist/nodeguard s3://tusaas-bucket/nodeguard/nodeguard --profile ecr-uploader
find . -type f -name "nodeguard"
ll
rm ./nodeguard
ll
aws s3 cp s3://tusaas-bucket/nodeguard/nodeguard ./nodeguard --profile ecr-uploader
find . -type f -name "nodeguard"
chmod +x nodeguard
./nodeguard
rm -rf build dist *.spec
find . -type f -name "nodeguard"
rm ./nodeguard
pyinstaller --onefile nodeguard.py --collect-all requests --copy-metadata requests
pyinstaller --onefile nodeguard.py   --hidden-import=requests   --hidden-import=urllib3   --hidden-import=certifi   --hidden-import=idna   --hidden-import=charset_normalizer
./dist/nodeguard
pip show requests
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install pyinstaller requests
ll
rm -rf build dist *.spec
pyinstaller --onefile nodeguard.py --collect-all requests
deactivate
./dist/nodeguard
aws s3 cp dist/nodeguard s3://tusaas-bucket/nodeguard/nodeguard --profile ecr-uploader
aws s3 cp dist/nodeguard s3://tusaas-bucket/nodeguard/nodeguard   --acl public-read --profile ecr-uploader
find . -type f -name "nodeguard"
curl -O http://acs.amazonaws.com/groups/global/AllUsers
curl -I https://tusaas-bucket.s3.amazonaws.com/nodeguard/nodeguard
ll
curl -O https://tusaas-bucket.s3.amazonaws.com/nodeguard/nodeguard
ll
./nodeguard
chmod +x nodeguard
./nodeguard
cat nginstall.sh 
rm hginstall.sh
ll
rm nginstall.sh
touch nginstall.sh
nano nginstall.sh 
sh nginstall.sh 
rm nginstall.sh
touch nginstall.sh
nano nginstall.sh 
set -e
APP_NAME="nodeguard"
INSTALL_DIR="$HOME/bin"
DOWNLOAD_URL="https://tusaas-bucket.s3.amazonaws.com/nodeguard/latest/nodeguard"
VERSION_URL="https://tusaas-bucket.s3.amazonaws.com/nodeguard/latest/version.txt"
LAMBDA_API_URL="https://kzpqkztu7f.execute-api.us-east-1.amazonaws.com/generate-api-key"
# Colores
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"
echo -e "${GREEN}🚀 Instalando $APP_NAME...${NC}\n"
# -----------------------------
# PATH
# -----------------------------
mkdir -p "$INSTALL_DIR"
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then echo -e "${YELLOW}➜ Agregando $INSTALL_DIR al PATH${NC}"; echo 'export PATH=$HOME/bin:$PATH' >> "$HOME/.bashrc"; export PATH="$HOME/bin:$PATH"; fi
# -----------------------------
# Detectar sudo
# -----------------------------
HAS_SUDO=false
if command -v sudo &> /dev/null && sudo -n true 2>/dev/null; then HAS_SUDO=true; fi
# -----------------------------
# jq (silencioso)
# -----------------------------
if ! command -v jq &> /dev/null; then echo -e "${YELLOW}➜ Instalando jq...${NC}";  ```
if command -v brew &> /dev/null; then
    brew install jq >/dev/null 2>&1
elif command -v apt-get &> /dev/null && [ "$HAS_SUDO" = true ]; then
    sudo apt-get update -y >/dev/null 2>&1
    sudo apt-get install -y jq >/dev/null 2>&1
elif command -v yum &> /dev/null && [ "$HAS_SUDO" = true ]; then
    sudo yum install -y jq >/dev/null 2>&1
else
    curl -sL https://github.com/jqlang/jq/releases/latest/download/jq-linux-amd64 -o "$INSTALL_DIR/jq"
    chmod +x "$INSTALL_DIR/jq"
fi
```;  fi
if ! command -v jq &> /dev/null; then echo -e "${RED}❌ No se pudo instalar jq${NC}"; exit 1; fi
echo -e "${GREEN}✔ jq listo${NC}\n"
# -----------------------------
# Client ID
# -----------------------------
CLIENT_ID=${1:-""}
if [ -z "$CLIENT_ID" ]; then read -p "🔑 Client ID: " CLIENT_ID; fi
