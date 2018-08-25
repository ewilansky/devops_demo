# FROM openjdk:8
FROM openjdk:8-jdk-alpine
# maintainer
LABEL maintainer "ethan@arrowheadlabs.io"
VOLUME /tmp
# ARG JAR_FILE=build/libs/gsspringbootdocker0.1.0.jar
# COPY ${JAR_FILE} app.jar
RUN echo $(docker --version)
COPY build/libs /app
RUN echo $(ls -1 /app/)
EXPOSE 8080
# ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app/gsspringbootdocker0.1.0.jar"]


# maintainer
# LABEL maintainer "ethan@arrowheadlabs.io"

# USER root

# VOLUME /tmp

# WORKDIR /home/gradle/project
# ARG JAR_FILE

# ADD ${JAR_FILE} app.jar
# COPY ${JAR_FILE} app.jar

# RUN ["/bin/bash", "-c", "cp ${JAR_FILE} app.jar"]
# RUN /bin/bash -c 'pwd'
# RUN /bin/bash -c 'echo $PWD'
# RUN ["/bin/bash", "-c", "echo ${PWD}"]
# RUN ["bin/bash", "-c", "ls /spring_boot_app/build/libs"]

# ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/spring_boot_app/build/libs/gs-spring-boot-docker-0.1.0.jar"]
# ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","./spring_boot_app/build/libs/gs-spring-boot-docker-0.1.0.jar"]
# EXPOSE 8888


# FROM openjdk:8
# COPY ./libs/libs/gs-spring-boot-docker-0.1.0.jar /usr/src/myapp
# WORKDIR /usr/src/myapp
# RUN javac Main.java
# CMD ["java", "libs/gs-spring-boot-docker-0.1.0.jar"]
# EXPOSE 8888