#!/usr/bin/env bash

user=$(cat /run/secrets/postgres-user)
pass=$(cat /run/secrets/postgres-passwd)

# using environment variables now, but considering changing this to write these property 
# values to /opt/sonarqube/conf/sonar.properties:
#sonar.jdbc.username=
#sonar.jdbc.password=
#sonar.jdbc.url
export SONARQUBE_JDBC_USERNAME="$user"
export SONARQUBE_JDBC_PASSWORD="$pass"
export SONARQUBE_JDBC_URL=jdbc:postgresql://db/sonar

# exec call transfers pid 1 to the upstream entrypoint so that signals get handled correctly. 
# the trailing "$@" passes any command line arguments. 
# adjust the value of $@ if there are args to process and extract from this script.
# run the base image command called by entrypoint:
echo "$@"
exec /opt/sonarqube/bin/run.sh "$@"