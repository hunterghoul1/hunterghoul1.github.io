echo "Update your system"
apt update
apt full-upgrade -y
apt install cat -y
apt install net-tools -y
apt install sudo -y
apt install gnupg2 -y
apt install wget -y
apt install -yq apache2-utils
apt install -yq apt-transport-https ca-certificates curl gnupg lsb-release
apt install -yq docker-ce docker-ce-cli containerd.io
apt install docker.io -y
apt install openjdk-17-jre -y
clear

echo "docker compose install"
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v5.0.1/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

clear

echo "Install openfire 5.0.3"

wget https://www.igniterealtime.org/downloadServlet?filename=openfire/openfire_5.0.3_all.deb -O install.deb

dpkg -i install.deb

rm install.deb

clear

echo "Install WAF"

wget https://waf.uusec.com/installer.sh -O installer.sh

chmod +x installer.sh

./installer.sh

cd

clear

echo "Add your tcadmin account"

adduser tcadmin

usermod -aG sudo tcadmin

usermod -aG docker tcadmin

echo "Run container"
docker run -d -p 8080:80 -p 4444:443 -p 4307:4307 -p 4310:4310 -e ADMIN_USER=tcadmin -e ADMIN_PASSWORD=mypass12345* -v /home/$USER/trueconf/server/lib:/opt/trueconf/server/var/lib trueconf/trueconf-server:stable --name
vcs_server

echo "DockMon Install"

echo 'services:
  dockmon:
    image: darthnorse/dockmon:latest
    container_name: dockmon
    restart: unless-stopped
    ports:
      - "8001:443"
    environment:
      - TZ=America/New_York
    volumes:
      - dockmon_data:/app/data
      - /var/run/docker.sock:/var/run/docker.sock
    healthcheck:
      test: ["CMD", "curl", "-k", "-f", "https://localhost:443/health"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  dockmon_data:' > docker-compose.yml

docker compose up -d

cd

clear

echo 'You may login in openfire admin panel use command:
ssh -L 9090:localhost:9090 user@serverip and complete your

Where user - your ssh username

Where serverip - your server ip

OpenFire admin panel: 127.0.0.1/9090

DockMon panel: https://ip:8001

Login: admin Pass: dockmon123

WAF panel: https://ip:4443

Login: admin Pass: #Passw0rd

TrueConf panel: https://127.0.0.1:4444 or http://127.0.0.1:8080

Login: tcadmin Pass: mypass12345*

For external access use command (by root): 

ssh -L 4444:localhost:4444 root@<ip_server>

Login: tcadmin Pass: mypass12345*

Enjoy!' > cred.txt

clear

echo "Complete installation!"

cat cred.txt