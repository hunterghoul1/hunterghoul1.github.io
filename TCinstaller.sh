clear
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
apt update
clear

echo "Add your tcadmin account"

adduser tcadmin

usermod -aG sudo tcadmin

usermod -aG docker tcadmin

clear

echo "Run container"

docker run -d -p 80:80 -p 443:443 -p 4307:4307 -p 4310:4310 -e ADMIN_USER=tcadmin -e ADMIN_PASSWORD=mypass12345* -v /home/tcadmin/trueconf/server/lib:/opt/trueconf/server/var/lib trueconf/trueconf-server:stable --name vcs_server

clear

echo "Enable autostart server"

docker container update --restart always vcs_server

echo "Admin panel: http://127.0.0.1/

For external access use command (by root): 

ssh -L 80:localhost:80 root@<ip_server>

Login: tcadmin

Pass: mypass12345*" > cred.txt

clear

cat cred.txt