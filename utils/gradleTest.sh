#!/usr/bin/env bash
cd ../spring-boot-demo
docker run --rm -v "${PWD}/spring-boot-demo":/home/gradle/project -w /home/gradle/project gradle gradle clean test
