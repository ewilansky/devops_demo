pipeline {
    agent { docker {
            image 'gradle:latest'
        } 
    }
    stages {
        stage('Build') {
            steps {
                // sh 'gradle --version'
                // sh 'gradle tasks'
                // sh 'gradle projects'
                // sh 'pwd'
                // sh 'ls -la'
                // sh 'cd spring_boot_app'
                sh 'gradle build -p /home/gradle/project'
            }
        }
    }
}