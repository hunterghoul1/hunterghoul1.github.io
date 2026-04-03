apt update
apt install wget -y
clear
echo 'Install docker'
wget https://hunterghoul1.github.io/dockerinstaller.sh -o dockerinstaller.sh && ./dockerinstaller.sh && rm dockerinstaller.sh
clear
echo 'Install tirreno'
curl -sL tirreno.com/t.yml | docker compose -f - up -d
