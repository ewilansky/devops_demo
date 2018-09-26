node {
    checkout scm
    /* Docker pipeline plugin installed in Jenkins container */
    docker.image('gradle:latest').inside {
        stage('Build') {
            // commented lines for testing and inspection
            // sh 'gradle --version'
            // sh 'gradle tasks'
            // sh 'gradle projects'
            sh 'gradle build -p /home/gradle/project'
        }
        stage('Test') {
            // TODO: replace with junit test running from built container
            // might move this to a later stage after building the container
            sh 'gradle test -p /home/gradle/project'

            // TODO: add Cucumber for acceptance testing. Consider plugins to tools like Jira, however
            // another tool is being considered...
        }
        stage('CodeAnalysis') {
            // will run sonarqube here
            sh 'gradle sonarqube -p /home/gradle/project'
        }
    }

    stage('AppImageBuild') {

        // NOTE: When building a different application, simply change the build-arg to point to the replacement jar
        def custom_app_image = docker.build("springboot", "--build-arg JAR_FILE=./spring-boot-demo/build/libs/spring-boot-demo-0.0.1-SNAPSHOT.jar -f spring-boot-demo/Dockerfile .")

        sh 'echo In Jenkins def, outside of container'
        sh 'echo $(docker --version)' // returns docker version on host

        custom_app_image.inside {
             sh 'echo Inside custom image'
        }
    }

    stage ('AppRunImage') {

    }
}