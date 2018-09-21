FROM openjdk:8-jdk-alpine
LABEL maintainer "ethan@arrowheadlabs.io"
VOLUME /tmp
ARG JAR_FILE
COPY ${JAR_FILE} app/app.jar
EXPOSE 8080
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app/app.jar"]