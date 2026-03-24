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
apt install unzip -y
clear

echo "docker compose install"
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v5.0.1/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

wget $(wget -q -O - https://api.github.com/repos/jitsi/docker-jitsi-meet/releases/latest | grep zip | cut -d\" -f4) -O jitsi.zip

mkdir jitsi

unzip jitsi.zip -d jitsi/

cd jitsi

mv * jitsi

cd jitsi

cp env.example .env

./gen-passwords.sh

mkdir -p ~/.jitsi-meet-cfg/{web,transcripts,prosody/config,prosody/prosody-plugins-custom,jicofo,jvb,jigasi,jibri}

clear

echo -n "введите ip сервера: "

read usrip

echo "PUBLIC_URL=https://$usrip:8443" >> .env

docker compose up -d

cd ..

echo "your jitsi panel: https://$usrip:8443" >> cred.txt

cat cred.txt