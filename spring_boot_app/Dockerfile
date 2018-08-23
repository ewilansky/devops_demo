# FROM openjdk
# VOLUME /tmp
# WORKDIR /home/gradle/project
# ARG JAR_FILE

# COPY ${JAR_FILE} app.jar
# Trying this as the preferred form...
# COPY ["${JAR_FILE}" "/app.jar"]

# RUN ["/bin/bash", "-c", "cp ${JAR_FILE} app.jar"]
# RUN /bin/bash -c 'pwd'
# RUN /bin/bash -c 'echo $PWD'
# RUN ["/bin/bash", "-c", "echo ${PWD}"]

# ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
# EXPOSE 8888


FROM openjdk:8
COPY ./libs/libs/gs-spring-boot-docker-0.1.0.jar /usr/src/myapp
WORKDIR /usr/src/myapp
# RUN javac Main.java
CMD ["java", "libs/gs-spring-boot-docker-0.1.0.jar"]
EXPOSE 8888