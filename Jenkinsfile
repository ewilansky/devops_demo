pipeline {
    agent { docker {
            image 'gradle:latest'
            // args '-v "$PWD"/spring_boot_app:/home/gradle/project -w /home/gradle/project'
            // customWorkspace '/home/gradle/project'
            // args '--rm -v "$PWD":/home/gradle/project -w /home/gradle/project gradle 
        } 
    }
    stages {
        stage('Build') {
            steps {
                // sh 'gradle --version'
                // sh 'gradle tasks'
                sh 'pwd'
                sh 'ls -la'
                sh 'cd spring_boot_app'
                sh 'gradle projects'
                sh 'gradle build --scan'
            }
        }
    }
}