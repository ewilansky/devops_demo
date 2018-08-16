pipeline {
    agent { docker {
            image 'gradle:latest'
            args '-v /Users/ethanw/code/ahl/devops_demo/spring_boot_app:/home/gradle/project -w /home/gradle/project'
            // args '--rm -v "$PWD":/home/gradle/project -w /home/gradle/project gradle 
        } 
    }
    stages {
        stage('build') {
            steps {
                // sh 'gradle --version'
                // sh 'gradle tasks'
                sh 'gradle build'
            }
        }
    }
}