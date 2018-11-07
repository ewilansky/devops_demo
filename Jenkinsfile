node {
    checkout scm
    stage('Scrub Pipeline') {
        // important to cleanup pipeline artifacts
        // add conditional logic here to find deployment
        sh 'kubectl delete deployments --ignore-not-found=true spring-boot-demo'
        sh 'kubectl delete services --ignore-not-found=true spring-boot-demo'
        sh 'rm /home/project/build/libs/*'
    }
    /* Docker pipeline plugin installed in Jenkins container */
    docker.image('gradle:latest').inside('--network=toolchain_demo_tc-net') {
        stage('Build') {
            // commented lines for inspection
            // sh  'gradle buid --scan' find build dependencies including transitive and build report
            // sh ' gradle dependencies' just list the dependencies, no report
            sh 'gradle bootJar -p /home/project --stacktrace'
        }
        stage('UnitTest & Linting') {
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
        stage('Publish Package') {
            sh 'gradle publish -p /home/project --stacktrace'
        }
        stage('Retrieve App') {
            sh 'curl -u admin:admin123 -X GET "http://package-repo:8081/repository/maven-snapshots/org/ahl/springbootdemo/spring-boot-demo/0.0.1-SNAPSHOT/spring-boot-demo-0.0.1-20181102.132114-1.jar" --output /home/project/build/libs/app.jar'
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
        sh 'kubectl create -f /kube/deploy/app_set/sb-demo-deployment.yaml'
    }
    stage('Configure Kube Load Balancer') {
        sh 'kubectl create -f /kube/deploy/app_set/sb-demo-service.yaml'
    }
}