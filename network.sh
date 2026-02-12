echo "Update your system"
apt update
apt full-upgrade -y
apt install cat -y
apt install net-tools -y
apt install openjdk-17-jre -y
apt install ufw
ufw allow 3478
apt install coturn -y
clear

echo "Install vpn service"

sudo bash -c "$(curl -sL https://github.com/Gozargah/Marzban-scripts/raw/master/marzban.sh)" @ install

clear

echo "Create your admin account for vpn panel:"

marzban cli admin create --sudo

clear

echo "Install openfire"

wget https://www.igniterealtime.org/downloadServlet?filename=openfire/openfire_5.0.3_all.deb -O install.deb

dpkg -i install.deb

rm install.deb

touch default.txt

echo 'You may login in admin panel VPN use command: 
ssh -L 8000:localhost:8000 user@serverip

You may login in openfire admin panel use command:
ssh -L 9090:localhost:9090 user@serverip and complete your

Where user - your ssh username

Where serverip - your server ip

VPN admin panel: 127.0.0.1:8000/dashboard

OpenFire admin panel: 127.0.0.1/9090

Enjoy!' >> default.txt

clear

echo "Complete installation!
"

cat default.txt