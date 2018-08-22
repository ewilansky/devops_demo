FROM openjdk:latest
VOLUME /tmp
WORKDIR /home/gradle/project
ARG JAR_FILE
COPY ${JAR_FILE} app.jar
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
EXPOSE 8888