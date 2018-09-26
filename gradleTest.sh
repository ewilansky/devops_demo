#!/usr/bin/env bash
docker run --rm -v "${PWD}/spring-boot-demo":/home/gradle/project -w /home/gradle/project gradle gradle clean test
