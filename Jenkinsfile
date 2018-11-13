def appArtifact
node() {
    checkout scm
    stage('Scrub Pipeline') {
        // important to cleanup pipeline artifacts
        // add conditional logic here to find deployment
        // remove app POD and any replicas
        sh 'kubectl delete deployments --ignore-not-found=true springboot-demo'
        // remove load balancer service
        sh 'kubectl delete services --ignore-not-found=true springboot-demo'
        sh 'rm -f /home/project/build/libs/*' // -f to avoid failure if dir is empty
    }
    /* Docker pipeline plugin installed in Jenkins container */
    docker.image('gradle:latest').inside('--network=toolchain_demo_tc-net') {
        stage('Build') {
            // commented lines for inspection
            // sh  'gradle buid --scan' // find build dependencies including transitive and build report
            // sh ' gradle dependencies' // just list the dependencies, no report
            sh 'gradle bootJar -p /home/project --info'
        }
        stage('UnitTest') {
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
            sh 'gradle publish -p /home/project --debug'
        }
        stage('Retrieve App') {
            sh 'echo temporarily put jar in: $WORKSPACE'
            sh 'curl -u admin:admin123 -X GET "http://package-repo:8081/repository/maven-snapshots/org/ahl/springbootdemo/spring-boot-demo/0.0.1-SNAPSHOT/spring-boot-demo-0.0.1-20181102.132114-1.jar" --output $WORKSPACE/app.jar'
            sh 'ls $WORKSPACE'
        }
    }

    stage('App Image Build') {

        // NOTE: When building a different application, simply change the build-arg to point to the replacement jar
        sh 'echo ls "workspace is now: $WORKSPACE"'
        def custom_app_image = docker.build("springboot", "--build-arg JAR_FILE=$WORKSPACE/app.jar -f spring-boot-demo/Dockerfile .")

        // sh 'echo In Jenkins def, outside of container'
        sh 'echo $(docker --version)' // returns docker version on host
    }

    stage ('Deploy To Kube') {
        sh 'kubectl create -f /kube/deploy/app_set/sb-demo-deployment.yaml'
    }
    stage('Configure Kube Load Balancer') {
        sh 'kubectl create -f /kube/deploy/app_set/sb-demo-service.yaml'
    }
}