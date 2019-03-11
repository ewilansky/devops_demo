#!/bin/bash
# script provided as part of an article by Curtis Yanko at: https://blog.sonatype.com/running-the-nexus-platform-behind-nginx-using-docker

jsonFile=$1

printf "Creating Integration API Script from $jsonFile\n\n"

curl -v -u admin:admin123 --header "Content-Type: application/json" 'http://localhost:8081/service/rest/v1/script/' -d @$jsonFile