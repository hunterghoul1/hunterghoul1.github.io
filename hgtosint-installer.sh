echo "Update system..."
apt update
apt full-upgrade -y
apt install python3-pip -y
apt install python3.12-venv -y
apt install unzip -y
apt install wget -y
apt install nohup -y
clear

echo "Install webmin"
curl -o webmin-setup-repo.sh https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh
sh webmin-setup-repo.sh
apt install webmin --install-recommends
clear

echo "Install HGT-OSINT"
cd ~
mkdir hgtosint && cd hgtosint
wget https://hunterghoul1.github.io/hgt-osint.zip -O hgt-osint.zip && unzip hgt-osint.zip
echo -n "Введите ваш токен бота: "
read usrtoken
echo "TELEGRAM_BOT_TOKEN=$usrtoken" >> .env
python3 -m pip install --upgrade pip > nul 2>&1
pip install -r requirements.txt --break-system-packages
python3 -m venv venv
nohup python3 main.py
python3 web_admin.py

cd ~
echo 'Admin panel: your_setup_ip:5000
Default login and pass - admin:admin' > hgt-osint-cred.txt