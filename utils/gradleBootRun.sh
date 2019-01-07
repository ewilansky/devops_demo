#!/usr/bin/env bash
cd ../spring-boot-demo
docker run --rm -v "$PWD":/home/gradle/project -w /home/gradle/project --network toolchain_demo_tc-net gradle gradle bootRun
