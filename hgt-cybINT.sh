# Hunter Ghoul Cyber Intelligence Platform

#docker install

apt update
apt install wget nano -y
apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)
curl -fsSL https://get.docker.com -o get-docker.sh
sh ./get-docker.sh
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v5.0.1/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
docker compose version

# opencti install


mkdir opencti
cd opencti
git clone https://github.com/OpenCTI-Platform/docker.git
cd docker


(cat << EOF
###########################
# DEPENDENCIES            #
###########################

MINIO_ROOT_USER=$(cat /proc/sys/kernel/random/uuid)
MINIO_ROOT_PASSWORD=$(cat /proc/sys/kernel/random/uuid)
RABBITMQ_DEFAULT_USER=opencti
RABBITMQ_DEFAULT_PASS=$(openssl rand -base64 32)
SMTP_HOSTNAME=localhost
OPENSEARCH_ADMIN_PASSWORD=changeme
ELASTIC_MEMORY_SIZE=4G

###########################
# COMMON                  #
###########################

XTM_COMPOSER_ID=8215614c-7139-422e-b825-b20fd2a13a23
COMPOSE_PROJECT_NAME=xtm

###########################
# OPENCTI                 #
###########################

OPENCTI_HOST=localhost
OPENCTI_PORT=8080
OPENCTI_EXTERNAL_SCHEME=http
OPENCTI_ADMIN_EMAIL=admin@opencti.io
OPENCTI_ADMIN_PASSWORD=ChangeMePlease
OPENCTI_ADMIN_TOKEN=$(cat /proc/sys/kernel/random/uuid)
OPENCTI_HEALTHCHECK_ACCESS_KEY=$(cat /proc/sys/kernel/random/uuid)
OPENCTI_ENCRYPTION_KEY=$(openssl rand -base64 32)

###########################
# OPENCTI CONNECTORS      #
###########################

CONNECTOR_EXPORT_FILE_STIX_ID=dd817c8b-abae-460a-9ebc-97b1551e70e6
CONNECTOR_EXPORT_FILE_CSV_ID=7ba187fb-fde8-4063-92b5-c3da34060dd7
CONNECTOR_EXPORT_FILE_TXT_ID=ca715d9c-bd64-4351-91db-33a8d728a58b
CONNECTOR_IMPORT_FILE_STIX_ID=72327164-0b35-482b-b5d6-a5a3f76b845f
CONNECTOR_IMPORT_DOCUMENT_ID=c3970f8a-ce4b-4497-a381-20b7256f56f0
CONNECTOR_IMPORT_FILE_YARA_ID=7eb45b60-069b-4f7f-83a2-df4d6891d5ec
CONNECTOR_IMPORT_EXTERNAL_REFERENCE_ID=d52dcbc8-fa06-42c7-bbc2-044948c87024
CONNECTOR_ANALYSIS_ID=4dffd77c-ec11-4abe-bca7-fd997f79fa36

###########################
# OPENCTI DEFAULT DATA    #
###########################

CONNECTOR_OPENCTI_ID=dd010812-9027-4726-bf7b-4936979955ae
CONNECTOR_MITRE_ID=8307ea1e-9356-408c-a510-2d7f8b28a0e2
EOF
) > .env


nano .env


echo 'vm.max_map_count=1048575' >> /etc/sysctl.conf


docker compose up -d



clear
echo "OpenCTI Install finished!"

# install opensearch

curl -fsSL https://raw.githubusercontent.com/opensearch-project/observability-stack/main/install.sh | bash

# install Neo4j

echo 'docker run -d \
--name neo4j \
-p 7474:7474 -p 7687:7687 \
-v neo4j_data:/data \
-v neo4j_plugins:/plugins \
-v neo4j_logs:/logs \
-v neo4j_conf:/var/lib/neo4j/conf \
-e NEO4J_AUTH=neo4j/Ваш_Надежный_Пароль \
-e NEO4J_PLUGINS='["apoc"]' \
-e NEO4J_dbms_security_procedures_unrestricted=apoc.* \
neo4j:latest' > neo4j.sh

nano neo4j.sh

sh neo4j.sh

iptables -A INPUT -p tcp --dport 7474 -j ACCEPT
iptables -A INPUT -p tcp --dport 7687 -j ACCEPT

# archivebox installer

mkdir -p ~/archivebox/data && cd ~/archivebox/data

docker run -d -v $PWD:/data -p 1234:8000 archivebox/archivebox

# create admin archivebox

usrContID=$(docker ps | grep archivebox | grep -o '^[^ ]*')

docker exec -it --user=archivebox $usrContID /bin/bash -c "archivebox manage createsuperuser"

docker exec -it --user=archivebox $usrContID /bin/bash -c "archivebox config --set PUBLIC_INDEX=False"

docker exec -it --user=archivebox $usrContID /bin/bash -c "archivebox config --set PUBLIC_SNAPSHOTS=False"

docker exec -it --user=archivebox $usrContID /bin/bash -c "archivebox config --set PUBLIC_ADD_VIEW=False"

echo 'Install full complete.
OpenCTI - http://$(hostname -I | awk '{print $1}'):8080
OpenSearch - http://$(hostname -I | awk '{print $1}'):5601
Neo4j - http://$(hostname -I | awk '{print $1}'):7474
ArchiveBox - http://$(hostname -I | awk '{print $1}'):1234' > cred.txt

clear

cat cred.txt
