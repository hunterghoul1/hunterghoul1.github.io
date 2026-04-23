#!/usr/bin/env bash


# ==============================
# Datashare Installer
# Hunter Ghoul Team
# ==============================

clear

# Colors (ANSI)
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
GRAY='\033[1;30m'
NC='\033[0m' # No Color

echo -e "${RED}"
echo "#############################################"
echo "#                                           #"
echo "#        HUNTER GHOUL TEAM INSTALLER         #"
echo "#                                           #"
echo "#############################################"
echo -e "${NC}"

echo -e "${CYAN}Product:${NC} Datashare"
echo -e "${CYAN}Team:${NC} Hunter Ghoul Team"
echo -e "${CYAN}Telegram:${NC} https://t.me/hunterghoul_team"
echo ""
echo -e "${GRAY}Preparing installation environment...${NC}"
echo ""

# 5-second countdown
for i in {5..1}; do
    echo -ne "${GREEN}Installation starts in $i seconds...${NC}\r"
    sleep 1
done

echo ""
echo -e "${GREEN}Starting installation...${NC}"
sleep 1

# --- installation logic continues below ---

set -e

### CONFIG
INSTALL_DIR=/opt/datashare
DATA_DIR=/opt/datashare-data
JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64

echo "🚀 Installing Datashare (production-safe setup)"

### SYSTEM
apt update -y
apt install -y \
  ca-certificates \
  curl \
  gnupg \
  git \
  unzip \
  lsb-release \
  make \
  build-essential

### JAVA 21
apt install -y openjdk-21-jdk
echo "export JAVA_HOME=$JAVA_HOME" > /etc/profile.d/java.sh
export JAVA_HOME=$JAVA_HOME
export PATH=$JAVA_HOME/bin:$PATH

### MAVEN
apt install -y maven
echo "export JAVA_HOME=$JAVA_HOME" > /root/.mavenrc

### DOCKER
if ! command -v docker >/dev/null; then
  curl -fsSL https://get.docker.com | sh
fi
apt install -y docker-compose-plugin

### KERNEL (Elasticsearch)
sysctl -w vm.max_map_count=262144
grep -q vm.max_map_count /etc/sysctl.conf || echo vm.max_map_count=262144 >> /etc/sysctl.conf

### DIRECTORIES
mkdir -p $INSTALL_DIR
mkdir -p $DATA_DIR
cd $INSTALL_DIR

### CLONE DATASHARE
git clone https://github.com/ICIJ/datashare.git .
chmod +x run.sh

### INFRA
docker compose up -d

### BUILD
make install
make app

### RUNTIME CONFIG
mkdir -p dist
cat > dist/datashare.conf <<EOF
mode=LOCAL
tcpListenPort=8080
bind=0.0.0.0

elasticsearchUri=http://localhost:9200
elasticsearchAddress=http://localhost:9200

redisUri=redis://localhost:6379
database.url=jdbc:postgresql://localhost/datashare
database.user=datashare
database.password=datashare
EOF

### START SCRIPT
cat > start.sh <<'EOF'
#!/bin/bash
nohup ./run.sh --mode LOCAL --elasticsearchAddress http://localhost:9200 \
  > datashare.log 2>&1 &
EOF
chmod +x start.sh

### SYSTEMD SERVICE
cat > /etc/systemd/system/datashare.service <<EOF
[Unit]
Description=ICIJ Datashare
After=network.target docker.service docker.socket
Requires=docker.service docker.socket

[Service]
Type=simple
User=root
WorkingDirectory=/opt/datashare
ExecStart=/opt/datashare/run.sh --mode LOCAL --elasticsearchAddress http://localhost:9200
Restart=always
RestartSec=10
LimitNOFILE=65536
Environment="JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64"

[Install]
WantedBy=multi-user.target
EOF

### AUTOSTART SCRIPTS
cat > enable-autostart.sh <<EOF
#!/bin/bash
systemctl daemon-reload
systemctl enable datashare
systemctl restart datashare
EOF
chmod +x enable-autostart.sh

cat > disable-autostart.sh <<EOF
#!/bin/bash
systemctl stop datashare
systemctl disable datashare
EOF
chmod +x disable-autostart.sh

echo "✅ Datashare installed"
echo "➡ Manual start: $INSTALL_DIR/start.sh"
echo "➡ Enable autostart: ./enable-autostart.sh"
echo "➡ Disable autostart: ./disable-autostart.sh"
echo "🌐 Web UI: http://$(hostname -I | awk '{print $1}'):8080"
