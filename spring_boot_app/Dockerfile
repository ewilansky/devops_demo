FROM openjdk:latest
VOLUME /tmp
# WORKDIR /home/gradle/project
ARG JAR_FILE
COPY ${JAR_FILE} app.jar
RUN /bin/bash -c 'pwd'
RUN /bin/bash -c 'echo $HOME;
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
EXPOSE 8888