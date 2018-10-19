node {
    checkout scm
    /* Docker pipeline plugin installed in Jenkins container */
    docker.image('gradle:latest').inside('--network=toolchain_demo_tc-net') {
        stage('Build') {
            // commented lines for inspection
            // sh  'gradle buid --scan' find build dependencies including transitive and build report
            // sh ' gradle dependencies' just list the dependencies, no report
            sh 'gradle bootJar -p /home/project --info'
        }
        stage('UnitTest And Linting') {
            // all unit test tasks, includes linting
            sh 'gradle test -p /home/project'
        }
        stage('BDD Test') {
            sh 'gradle cucumberTest -p /home/project'
        }
        stage('Integration Test') {
            sh 'gradle integrationTest -p /home/project'
        }
        stage('Code Analysis') {
            // run sonarqube
            sh 'gradle sonarqube -p /home/project'
        }
    }

    stage('App Image Build') {

        // NOTE: When building a different application, simply change the build-arg to point to the replacement jar
        def custom_app_image = docker.build("springboot", "--build-arg JAR_FILE=./spring-boot-demo/build/libs/spring-boot-demo-0.0.1-SNAPSHOT.jar -f spring-boot-demo/Dockerfile .")

        sh 'echo In Jenkins def, outside of container'
        sh 'echo $(docker --version)' // returns docker version on host

        custom_app_image.inside {
             sh 'echo Inside custom image'
        }
    }

    stage ('Deploy To Kube') {
        docker.withServer('tcp://docker.for.mac.localhost:1234') {
            sh 'echo Working on deploy to Kubernetes docker single-node cluster'
            sh 'docker stack deploy app --compose-file /home/project/kube-compose.yml'
        }
    }
    // docker.withDockerServer('unix:///var/run/docker.sock') {
    // docker.withServer('tcp://docker.for.mac.localhost') {
        //sh 'echo Working on deploy to Kubernetes docker single-node cluster'
        //sh 'docker stack deploy --compose-file /home/project/kube-compose.yml tc'
    //}
        
}