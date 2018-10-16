#!/usr/bin/env bash
# remove the container
# docker rm -f spring-boot-demo
docker run --name="spring-boot-demo" --publish 8081:8081 springboot
docker rm -f spring-boot-demo
