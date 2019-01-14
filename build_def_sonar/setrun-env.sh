#!/usr/bin/env bash

# bind mounting secrets to a unique target because sonarqube already has a /run folder that is preventing 
# the projection of /run/secrets into the container
user=$(cat /usr/local/secrets/sonarqube-user)
export SONARQUBE_JDBC_USERNAME="$user"
pass=$(cat /usr/local/secrets/sonarqube-passwd)
export SONARQUBE_JDBC_PASSWORD="$pass"

export SONARQUBE_JDBC_URL=jdbc:postgresql://db/sonar

# exec call transfers pid 1 to the upstream entrypoint so that signals get handled correctly. 
# the trailing "$@" passes any command line arguments. 
# adjust the value of $@ if there are args to process and extract from this script.
# run the base image command called by entrypoint:
echo "$@"
exec /opt/sonarqube/bin/run.sh "$@"