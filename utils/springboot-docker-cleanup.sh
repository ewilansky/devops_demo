docker rm -f $(docker ps --filter "Name=tc_springboot-demo" -q)
docker rmi $(docker images --filter "reference=springboot" -q)
