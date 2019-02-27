#!/bin/bash
# script provided as part of an article by Curtis Yanko at: https://blog.sonatype.com/running-the-nexus-platform-behind-nginx-using-docker

name=$1
printf "Running Integration API Script $name\n\n"

curl -v -X POST -u admin:admin123 --header "Content-Type: text/plain" "http://localhost:8081/service/rest/v1/script/$1/run"

printf "Deleting Integration API Script from Nexus"
# curl -v -X DELETE -u admin:admin123 --header "Content-Type: application/json" "http://localhost:8081/service/rest/v1/script/$1"

curl -v -X DELETE -u admin:admin123 "http://localhost:8081/service/rest/v1/script/$1" -H "accept: application/json"