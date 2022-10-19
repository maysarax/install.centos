docker ps -a


docker ps -a -f name=moodle
docker ps -a -f name=moodledb



docker container stop moodle
docker container stop moodledb


docker container start moodle
docker container start moodledb


docker container restart moodle
docker container restart moodledb


docker logs moodle
docker logs moodledb

