pipeline {
    agent { docker {
            image 'gradle:latest'
            args '-v /home/gradle/project:/home/gradle/project -w /home/gradle/project'
            // customWorkspace '/home/gradle/project'
            // args '--rm -v "$PWD":/home/gradle/project -w /home/gradle/project gradle 
        } 
    }
    stages {
        stage('Build') {
            steps {
                // sh 'gradle --version'
                // sh 'gradle tasks'
                sh 'gradle build'
            }
        }
    }
}