// pipeline {
//     agent { docker { image 'gradle:latest' } }
//     stages {
//         stage('build') {
//             steps {
//                 sh 'gradle --version'
//             }
//         }
//     }
// }

pipeline {
    agent {
        docker {
            args '--rm -v "$PWD":/home/gradle/project -w /home/gradle/project gradle'
            image 'gradle:latest'
            reuseNode true
        }
    }
    stages {
        stage('build') {
            steps {
                sh 'gradle --version'
            }
        }
    }
}