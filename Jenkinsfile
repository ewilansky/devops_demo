// pipeline {
//     agent { docker {
//             image 'gradle:latest'
//         } 
//     }
//     stages {
//         stage('Build') {
//             steps {
//                 // commented lines for testing and inspection
//                 // sh 'gradle --version'
//                 // sh 'gradle tasks'
//                 // sh 'gradle projects'
//                 // sh 'pwd'
//                 // sh 'ls -la'
//                 sh 'gradle build -p /home/gradle/project'
//             }
//         }
//     }
// }

node {
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
    }
}