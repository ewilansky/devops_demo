#!/bin/bash

declare -a files=('nexus_password.txt' 'nexus_usr.txt' 'postgres_password.txt' 'postgres_usr.txt' 'sonarqube_password.txt' 'sonarqube_usr.txt')

if [ ! -d secrets ]; then
    mkdir ./secrets
    cd ./secrets

    for f in "${files[@]}"
    do
        echo >> "$f"
    done
    echo 'secrets directory and files created. Please add passwords'
else
    echo 'secrets directory exists'
fi