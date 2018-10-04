node {
    checkout scm
    /* Docker pipeline plugin installed in Jenkins container */
    // docker.network='devops_demo_demo-net'
    docker.image('gradle:latest').inside('--network=devops_demo_demo-net') {
        stage('Build') {
            // commented lines for inspection
            // sh  'gradle buid --scan' find build dependencies including transitive and build report
            // sh ' gradle dependencies' just list the dependencies, no report
            sh 'gradle bootJar -p /home/gradle/project'
        }
        stage('UnitTest And Linting') {
            // all verification tasks, including tests and linting
            sh 'gradle check -p /home/gradle/project'
        }
        stage('BDD Test') {
            sh 'gradle cucumber -p /home/gradle/project'
        }
        stage('Code Analysis') {
            // run sonarqube
            sh 'gradle sonarqube -p /home/gradle/project'
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

    stage ('DeployImageToKubernetes') {
        // this uses a Minikube container for this local demo. Mechanics of a large, remote deployment do not change
        sh 'echo Deploying to Kubernetes Minikube cluster'

    }
}