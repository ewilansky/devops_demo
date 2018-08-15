pipeline {
    agent { docker { image 'gradle:latest' } }
    stages {
        stage('build') {
            steps {
                // sh 'gradle --version'
                // sh 'gradle tasks'
                sh 'cd ./spring_boot_app'
                sh 'gradle build && java -jar build/libs/gs-spring-boot-docker-0.1.0.jar
            }
        }
    }
}