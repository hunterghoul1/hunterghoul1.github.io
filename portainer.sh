apt update 
wget https://hunterghoul1.github.io/dockerinstaller.sh -O docker.sh
chmod +x docker.sh
sh docker.sh
rm docker.sh
echo 'services:
  portainer:
    container_name: portainer
    image: portainer/portainer-ce:lts
    restart: always
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer_data:/data
    ports:
      - 9443:9443
      #- 8000:8000  # Remove if you do not intend to use Edge Agents

volumes:
  portainer_data:
    name: portainer_data

networks:
  default:
    name: portainer_network' > portainer-compose.yaml
docker compose -f portainer-compose.yaml up -d
echo 'Wait init container'
sleep 10
clear
echo 'Use this token for install admin account'
docker logs portainer 2>&1 | grep setup_token
echo 'Admin panel: https://your_ip_or_domain:9443'
