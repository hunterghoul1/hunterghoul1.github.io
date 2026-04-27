apt remove golang-go
apt install tar git -y
which go  # определите путь к исполняемому файлу
sudo rm -rf /usr/local/go  # удалите каталог (подставьте свой путь)
go version  # проверьте, что Go удалён (должна быть ошибка)
wget https://go.dev/dl/go1.26.2.linux-amd64.tar.gz -O go.tar.gz
tar -C /usr/local -xzf go.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
' >> ~/.profile
source ~/.profile  # или source ~/.bashrc

mkdir -p $HOME/go/{bin,src}
go version

cd
git clone https://github.com/okpulse/osint-stividor.git

#reopen down for edit site
cd osint-stividor
go mod tidy
nano cmd/server/main.go
nano cmd/osint-stividor/main.go
nano internal/app/static/index.html
nano internal/app/static/app.js
cp ~/favicon.png ~/osint-stividor/internal/app/static/favicon.png
go build -o ~/stividor-run ./cmd/server

echo 'simple run: ./stividor-run' > ~/readme.txt

cd ~/
clear
cat readme.txt
./stividor-run
