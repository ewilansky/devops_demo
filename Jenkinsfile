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
            sh 'gradle --version'
        }
    }
}
node {
    stage('AppImageBuild') {

        // def custom_app_image = docker.build("springboot", "-f springbootapp/Dockerfile ./springbootapp")
        def custom_app_image = docker.build("springboot", "--build-arg JAR_FILE=./springbootapp/build/libs/gs-spring-boot-docker-0.1.0.jar -f springbootapp/Dockerfile .")

        sh 'echo In Jenkins def, outside of container'
        sh 'echo $(docker --version)' // returns docker version on host

        custom_app_image.inside {
             sh 'echo Inside custom image'
        }

        // "--build-arg JAR_FILE=./spring_boot_app/build/libs/gs-spring-boot-docker-0.1.0.jar .")

    
    }

}