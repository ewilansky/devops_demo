node {
    checkout scm
    /* Docker pipeline plugin installed in Jenkins container */
    docker.image('gradle:latest').inside {
        stage('Build') {
            // commented lines for testing and inspection
            // sh 'gradle --version'
            // sh 'gradle tasks'
            // sh 'gradle projects'
            // sh 'pwd'
            // sh 'ls -la'
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
    // sh 'pwd'
    // sh 'ls -la'
        def custom_app_image = docker.build("springboot", "./spring_boot_app")

        custom_app_image.inside {
             sh 'echo Inside custom image'
             // sh 'ls -la'
             // sh 'pwd'
             // sh 'tree'
             sh 'cp ./spring_boot_app/build/libs/gs-spring-boot-docker-0.1.0.jar /app.jar'
        }

        // "--build-arg JAR_FILE=./spring_boot_app/build/libs/gs-spring-boot-docker-0.1.0.jar .")
    }

}