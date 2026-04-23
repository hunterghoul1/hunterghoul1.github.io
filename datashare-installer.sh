#!/usr/bin/env bash
set -e

# ==============================
# Datashare Installer
# Hunter Ghoul Team
# ==============================

clear

##### COLORS #####
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GRAY='\033[1;30m'
NC='\033[0m'

##### UI FUNCTIONS #####
banner() {
  echo -e "${RED}"
  echo "#################################################"
  echo "#                                               #"
  echo "#        H U N T E R  G H O U L  T E A M          #"
  echo "#                                               #"
  echo "#            D A T A S H A R E                   #"
  echo "#                I N S T A L L E R               #"
  echo "#                                               #"
  echo "#################################################"
  echo -e "${NC}"
}

section() {
  echo ""
  echo -e "${CYAN}▶▶▶ $1${NC}"
  echo -e "${GRAY}-------------------------------------------------${NC}"
}

step() {
  echo -ne "${YELLOW}  • $1... ${NC}"
}

spinner() {
  local pid=$1
  local spin='-\|/'
  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    i=$(( (i+1) %4 ))
    printf "\r${GRAY}    [%c] working...${NC}" "${spin:$i:1}"
    sleep 0.2
  done
  printf "\r"
}

run() {
  command="$1"
  bash -c "$command" &>/tmp/datashare_install.log &
  pid=$!
  spinner $pid
  wait $pid
  echo -e "${GREEN}[ OK ]${NC}"
}

##### INTRO #####
banner
echo -e "${CYAN}Product:${NC} Datashare"
echo -e "${CYAN}Team:${NC} Hunter Ghoul Team"
echo -e "${CYAN}Telegram:${NC} https://t.me/hunterghoul_team"
echo ""
echo -e "${GRAY}Initializing secure production installer...${NC}"
echo ""

for i in {5..1}; do
  echo -ne "${GREEN}Installation begins in $i seconds...${NC}\r"
  sleep 1
done

echo -e "\n${GREEN}Starting installation...${NC}"
sleep 1

##### CONFIG #####
INSTALL_DIR=/opt/datashare
DATA_DIR=/opt/datashare-data
JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64

##### SYSTEM #####
section "System preparation"
step "Updating package index"
run "apt update -y"

step "Installing core dependencies"
run "apt install -y ca-certificates curl gnupg git unzip lsb-release make build-essential"

##### JAVA #####
section "Java 21 setup"
step "Installing OpenJDK 21"
run "apt install -y openjdk-21-jdk"

step "Configuring JAVA_HOME"
run "echo 'export JAVA_HOME=$JAVA_HOME' > /etc/profile.d/java.sh"

export JAVA_HOME=$JAVA_HOME
export PATH=$JAVA_HOME/bin:$PATH

##### MAVEN #####
section "Maven build system"
step "Installing Maven"
run "apt install -y maven"

step "Configuring Maven environment"
run "echo 'export JAVA_HOME=$JAVA_HOME' > /root/.mavenrc"

##### DOCKER #####
section "Docker infrastructure"
step "Checking Docker installation"
if ! command -v docker &>/dev/null; then
  run "curl -fsSL https://get.docker.com | sh"
else
  echo -e "${GREEN}[ OK ] Docker already installed${NC}"
fi

step "Installing docker-compose plugin"
run "apt install -y docker-compose-plugin"

##### KERNEL #####
section "Kernel tuning (Elasticsearch)"
step "Applying vm.max_map_count"
run "sysctl -w vm.max_map_count=262144"

run "grep -q vm.max_map_count /etc/sysctl.conf || echo vm.max_map_count=262144 >> /etc/sysctl.conf"

##### DIRECTORIES #####
section "Filesystem layout"
step "Creating directories"
run "mkdir -p $INSTALL_DIR $DATA_DIR"

cd $INSTALL_DIR

##### SOURCE #####
section "Datashare source"
step "Cloning repository"
run "git clone https://github.com/ICIJ/datashare.git ."

step "Preparing run script"
run "chmod +x run.sh"

##### INFRA #####
section "Containers"
step "Starting infrastructure (Docker Compose)"
run "docker compose up -d"

##### BUILD #####
section "Build process"
step "Running make install"
run "make install"

step "Building application"
run "make app"

##### CONFIG #####
section "Runtime configuration"
step "Writing datashare.conf"
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
echo -e "${GREEN}[ OK ]${NC}"

##### SERVICE #####
section "Systemd integration"
step "Creating service unit"
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
Environment="JAVA_HOME=$JAVA_HOME"

[Install]
WantedBy=multi-user.target
EOF
echo -e "${GREEN}[ OK ]${NC}"

##### FINISH #####
echo ""
echo -e "${GREEN}✅ Datashare installation completed successfully${NC}"
echo -e "${CYAN}▶ Start manually:${NC} $INSTALL_DIR/start.sh"
echo -e "${CYAN}▶ Enable autostart:${NC} systemctl enable datashare --now"
echo -e "${CYAN}▶ Web UI:${NC} http://$(hostname -I | awk '{print $1}'):8080"
echo ""
echo -e "${GRAY}Hunter Ghoul Team — stay sharp.${NC}"
