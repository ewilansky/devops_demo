# Toolchain Demonstration

This goal of this project is to provide a fully functional CI/CD pipeline that is portable, easy to setup, does not rely on a network connection, uses only open source tooling and can run on a laptop with 16 GB of RAM.

**Important** This is purely a demonstration of a CI/CD pipeline. Usernames and passwords have not been changed from the default. For an operational system, it's important that all credentials are unique and stored as configurable secrets. Read the Configuring Secrets section for details.  

## Pipeline Foundation

All tools in this pipeline run in Docker containers. The containers are written to be single-purpose. For example, the build container runs Gradle and the repository container runs Nexus 3 OSS. Any container in the pipeline can be removed (deleted) and recreated without losing history.

The continuous deployment (CD) part of the pipeline relies on Kubernetes as the final deployment target. To achieve Kubernetes deployment without a network connection and to make it as simple as possible, the demonstration uses Docker Kubernetes integration. I explain how to configure this in the setup section.

## Prerequisites

Docker v. 1.8 or later for OS X or Windows
16 GB of RAM
The Git client for your operating system

## Setup Instructions Specific to Your Host Operating System

These instructions are current as of Docker v 2.0.0.3. If you are on a later version, configuration might be different.

1. In Docker for Mac, enable Kubernetes integration from the Docker > Preferences > Kubernetes tab.

      or

1. In Docker for Windows, enable Kubernetes integration from Docker > Settings > Kubernetes option.

### Setup instructions for Mac or Windows systems

1. From the Kubernetes tab/option:

    OSX: ensure or select the Kubernetes orchestration radio button.

    Windows: ensure or select the Deploy Docker Stacks to Kubernetes by default check box.

2. Once Docker and Kubernetes are started, open a command prompt.

3. Navigate to a directory where you want to clone this project/repository.

4. Clone the repository:

   `git clone https://github.com/ewilansky/toolchain_demo.git`

5. Change directory to the root of the repository:

   `cd toolchain_demo`

6. Verify that there are no containers already running:
  
   `docker ps`

   If this command returns containers, I suggest you stop any running containers. This is a good idea to ensure you have enough memory resources to run the containers and to avoid port collisions.
   In bash, you can stop all running containers by typing:

   `docker stop $(docker ps -q)`

7. Start the long-running pipeline tools (see Long Running Containers for details)

   `docker-compose up -d`

   This command will start four containers that support the pipeline. You should see something like this:  
  
   Creating network "toolchain_demo_tc-net" with the default driver  
   Creating nexus     ... done  
   Creating sonarqube ... done  
   Creating jenkins   ... done  
   Creating postgres  ... done  

8. To verify the containers are running:

   `docker ps`

   This command should return the names of four containers: nexus, jenkins, sonarqube and postgres. If you see nore containers, you already run Docker and have running containers. Unless you have significant memory resources, I suggest you stop the other containers while running this demonstration. Also, it's possible that existing, running containers could be using the same ports configured for this demonstration. Stopping the other running containers is sufficient to avoid port collisions. If you're not sure how to stop containers, read about the *docker stop* command option.

### Running the toolchain

There are web-based UI's for Jenkins, Sonarqube and Nexus. To verify they are functional and to run the pipeline, follow these steps:

#### Jenkins

The first time you attempt to access the Jenkins UI, you will need to unlock it by setting an initial administrator password.

1. On your host, browse to http://localhost:8080 and the following screen will appear:

![image of the jenkins unlock page](./img/unlockjenkins.png "The Jenkins Unlock Page")

The location of the initialAdminPassword is in the jenkins_home directory on your host. The  path starting from the toolchain_demo directory is: ./jenkins_home/secrets/initialAdminPassword. Following the remaining screens that Jenkins presents. You can accept the standard plugins for this simple setup.

TODO: CONTINUE FROM HERE. JENKINS PLUGINS ARE REQUIRED, JENKINS FILE DEFINITION DIDN'T APPEAR AND SONARQUBE ISN'T OPERATIONAL

logon id: admin  
password: admin

The sample project "Demo Pipeline" should appear. You can run the project directly from the Jenkins classic interface by clicking the play icon on the right side of the row.

Alternatively, you can use the Blue Ocean plugin UI to run the project.

1. Click the Open Blue Ocean link in the left navigation.
2. From the Blue Ocean UI, click the Demo Pipeline project then click the Branches tab.
3. Hover your mouse to the far right of the row to reveal the Play icon and click it to run the job.

To learn more about Jenkins, visit https://jenkins.io

#### Sonarqube

http://localhost:9000  
login id: admin  
password: admin

A new sonar database was created for SonarQube when docker-compose ran. In this new database, you must generate a logon token. Gradle uses this token to access Sonarqube for code analysis. Therefore, when you logon, you will be presented with this screen:

![image of the sonarqube set logon token page](./img/settokensonar.png "The SonarQube Set Logon Token Page")

1. Enter sonar in the token name box and click Generate
2. Copy the token value to your clipboard and click Continue
3. Edit ./spring-boot-demo/gradle.properties and replace the token value for systemProp.sonar.login.
4. Check-in the updated gradle.properties file to the SCM [TODO: SETUP LOCAL GIT SERVER]

If you ran the pipeline successfully, you will see the spring-boot-demo project appearing. Click on the spring-boot-demo link to see code metrics in SonarQube.

To learn more about Sonarqube, visit https://www.sonarqube.org

#### Nexus

http://localhost:8088  
login id: admin  
password: admin123

If you ran the pipeline succesfully, you will see the project dependencies cached in the maven-central repository.

1. In the left navigation, click Browse.
2. From the table that appears, click maven-central to see expandable trees showing project dependencies.

The pipeline also copied the spring-boot-demo jar to maven-snapshots.

1. In the left navigation, click Browse.
2. From the table that appears, click maven-snapshots to see an expandable tree of the spring-boot-demo snapshot.

To learn more about the Nexus Repository Manager, click the question mark icon on the right side of the top navigation menu and then select Documentation.

#### Kubernetes

To verify that the container has been built and deployed to Kubernetes:

1. Open a commandline and type:  
      `kubectl get deployments`  
   You should see the springboot-demo deployment listed
2. Then type:  
   `kubectl get services`  
   You should see two entries, one for the Kubernetes cluster IP and a second one for the spring-bootdemo load balancer.  

To see the application running, navigate to http://localhost:8081/api/books or use curl. In either case, the application will return two JSON formatted book entries.

## More About This Demonstration

There are quite a few more tools in the toolchain that weren't covered in the quick start above. For example, Gradle runs many of the build tasks in the pipeline. The following diagram shows the entire pipeline:

![image of the toolchain pipeline](./img/toolchain.png "The Toolchain Pipeline")

## Tools Configuration

The following containers that you generated earlier are setup to be long-running and are configured in docker-compose:

- Jenkins
- Nexus
- Sonarqube
- Postgres

Except for Postgres, you interacted directly with the other containers. Postgres in the database used to persist data collected by SonarQube.

While the gradle wrapper (gradlew) is part of the project, the pipeline does not use the wrapper. Instead, there is a separate Gradle container generated to run the tasks defined in Jenkins. The gradle wrapper is useful for troubleshooting and developing the pipeline, which is why I left it in place.

The spring-boot-demo jar is packaged in the openjdk:8-jdk-alpine image by docker in the pipeline. This image is the source of the container that gets deployed into Kubernetes.

## Configuring Secrets

Tools in the CI/CD toolchain use credentials for access control. This section details how to configure each tool requiring a logon with credentials stored locally and outside of source control.

### Secrets setup in this Toolchain Demo to Secre Credentials

1. Create a directory at the root of this project and name it **secrets**
2. In the subsections below, you will create two text files, one for the user account name and the other for the password following this convention:

   [*toolname*]_usr.txt and [*toolname*]_password.txt where *toolname* is the specific tool, such as postgres or sonarqube.

At the root of docker-compose.yml, Docker secrets are globally configured:

    secrets:
      postgres-user:
        file: ./secrets/postgres_usr.txt
      postgres-passwd:
        file: ./secrets/postgres_password.txt
      sonarqube-user:
        file: ./secrets/sonarqube_usr.txt
     sonarqube-passwd:
        file: ./secrets/sonarqube_password.txt

and then locally configured to scope each credential set down to the right service. How the secrets are locally scoped are described in the tool-specific sections next.

### Postgres Credential Management

The official Postgres image supports the use of Docker secrets by recognizing certain variable names followed by _FILE. You can read more about this in the official Postgres Docker repository at **TODO**. In the case of this demonstration, Docker secrets are passed to the Postgres container using the following two variable names and values in the db service section of docker-compose.yml:

    POSTGRES_PASSWORD_FILE: /run/secrets/postgres-passwd
    POSTGRES_USER_FILE: /run/secrets/postgres-user

These secrets defined globally in docker-compose-yml are scoped to the Postgres container via the simple secrets syntax also in the db service section of docker-compose.yml:

    secrets:
      - postgres-user
      - postgres-passwd

### Sonarqube Credential Management

The official Sonarqube image does not support Docker secrets. Therefore, this toolchain demo includes a custom Sonarqube image contained in the **build_def_sonar** folder. When this image is built, Docker copies the setrun-env.sh script into the image via dockerfile. This script looks in the /usr/local/secrets folder inside the image for credential information.

The Sonarqube service section of Docker-compose.yml locally binds /usr/local/secrets into the container, as shown:

    secrets:  
       - source: sonarqube-passwd  
         target: /usr/local/secrets/sonarqube-passwd
       - source: sonarqube-user  
         target: /usr/local/secrets/sonarqube-user

### Nexus Repository Credential Management

TODO