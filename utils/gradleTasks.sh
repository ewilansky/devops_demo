#!/usr/bin/env bash
cd ../spring-boot-demo
echo $PWD
docker run --rm -v "$PWD":/home/gradle/project -w /home/gradle/project --network toolchain_demo_tc-net gradle gradle tasks
