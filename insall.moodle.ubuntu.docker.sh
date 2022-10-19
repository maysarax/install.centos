apt-get update
apt-get install docker.io


sudo systemctl start docker

sudo systemctl enable docker


docker network create moodle-network

docker pull mariadb

docker pull bitnami/moodle


docker images

docker volume create mariadb-data

docker volume inspect mariadb-data


ln -s /var/lib/docker/volumes/mariadb-data/_data /mariadb


docker run -d --name moodledb -v mariadb-data:/var/lib/mysql --network moodle-network -e "MYSQL_ROOT_PASSWORD=kamisama123" -e MYSQL_USER=moodle -e "MYSQL_PASSWORD=kamisama123" -e "MYSQL_DATABASE=moodle" mariadb


docker volume create moodle-data

docker volume inspect moodle-data


ln -s /var/lib/docker/volumes/moodle-data/_data /moodle

docker run -d --name moodle -p 80:8080 -p 443:8443 -v moodle-data:/bitnami/moodle --network moodle-network -e MOODLE_DATABASE_HOST=moodledb -e MOODLE_DATABASE_USER=moodle -e MOODLE_DATABASE_PASSWORD=kamisama123 -e MOODLE_DATABASE_NAME=moodle bitnami/moodle:latest




