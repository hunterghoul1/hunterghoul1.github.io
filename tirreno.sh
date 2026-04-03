apt update
apt install wget -y
clear
echo 'Install docker'
wget https://hunterghoul1.github.io/dockerinstaller.sh -O dockerinstaller.sh && chmod +x dockerinstaller.sh && ./dockerinstaller.sh && rm dockerinstaller.sh
clear
echo 'Install tirreno'
echo -n 'ip server: '
read usrip
echo -n 'port tirreno: '
read usrport
echo '# tirreno with PostgreSQL
#
# Signup via http://localhost:8585/signup

services:
  tirreno-app:
    image: tirreno/tirreno:latest
    pull_policy: always
    ports:
      - "$usrport:80"
    environment:
      DATABASE_URL: "postgres://tirreno:secret@tirreno-db:5432/tirreno"
      SITE: "$usrip:8585"
      FORCE_HTTPS: "false"
    volumes:
      - tirreno-config:/var/www/html/config/local
      - tirreno-logs:/var/www/html/assets/logs
    networks:
      - tirreno-network
    depends_on:
      - tirreno-db

  tirreno-db:
    image: postgres:15
    environment:
      POSTGRES_DB: tirreno
      POSTGRES_USER: tirreno
      POSTGRES_PASSWORD: secret
    volumes:
      - tirreno-db:/var/lib/postgresql/data
    networks:
      - tirreno-network

networks:
  tirreno-network:

volumes:
  tirreno-config:
  tirreno-logs:
  tirreno-db:' > docker-compose.yml

docker compose up -d
