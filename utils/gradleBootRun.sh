#!/usr/bin/env bash
cd ../spring-boot-demo
docker run --rm -v "$PWD":/home/gradle/project -w /home/gradle/project gradle gradle bootRun
