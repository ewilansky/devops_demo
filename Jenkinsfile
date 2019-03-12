// import jenkins.model.*
// jenkins = Jenkins.instance

node() {
    checkout scm
    stage('Scrub Pipeline') {
        // important to cleanup pipeline artifacts
        sh 'kubectl delete deployments --ignore-not-found=true springboot-demo'
        // remove load balancer service
        sh 'kubectl delete services --ignore-not-found=true springboot-demo'
        sh 'rm -f /home/project/build/libs/*' // -f to avoid failure if dir is empty
    }
    /* Docker pipeline plugin installed in Jenkins container */
    // gradle 4.10 image reference: gradle:4.10.3-jdk-slim
    // gradle 5.x reference: gradle:latest
    docker.image('gradle:4.10.3-jdk-slim').inside('--network=toolchain_demo_tc-net') {
        def UnitTestTasks = [:]
        def IntTestAndAnalysisTasks = [:]

        stage('Build') {
            // commented lines for inspection
            // sh  'gradle buid --scan' // find build dependencies including transitive and build report
            // sh ' gradle dependencies' // just list the dependencies, no report
            sh 'gradle bootJar -p /home/project --info'
        }

        UnitTestTasks['Unit Tests'] = {
            stage('Unit Tests') {
                // all unit test tasks
                sh 'gradle test -p /home/project'
            }
        }
        UnitTestTasks['BDD Tests'] = {
            stage('BDD Tests') {
                sh 'gradle cucumberTest -p /home/project'
            }
        }
        IntTestAndAnalysisTasks['Integration Tests'] = {
            stage('Integration Tests') {
                sh 'gradle integrationTest -p /home/project'
            }
        }
        IntTestAndAnalysisTasks['Code Analysis'] = {
            stage('Code Analysis') {
                // run sonarqube
                sh 'gradle sonarqube -p /home/project'
            }
        }

        parallel UnitTestTasks
        parallel IntTestAndAnalysisTasks

        stage('Publish Package') {
            sh 'gradle publish -p /home/project'
        }
        stage('Retrieve App') {
            withCredentials([file(credentialsId: 'nexus_usr', variable: 'NEXUS_USR'), file(credentialsId: 'nexus_password', variable: 'NEXUS_PASSWORD')]) {
                user = $NEXUS_USR + ':' + $NEXUS_PASSWORD
                apiBase = "http://package-repo:8081/service/rest/v1/search/assets/download"
                artifactMd5Hash = "1373ba65e2f2845af90e479e4bf7f40b"
                group = "org.ahl.springbootdemo"
                name = "spring-boot-demo"
            }

            // artifact output directory
            sh "mkdir -p output"
            // retrieve the artifact from the nexus maven2 repo
            sh "curl -L -u ${user} -X GET '${apiBase}?group=${group}&name=${name}&maven.extension=jar&md5=${artifactMd5Hash}' --output ./output/app.jar"
            // stash for retrieval during image build
            stash name: 'app', includes: 'output/*'
        }
    }

    stage('App Image Build') {
        // NOTE: When building a different application, simply change the build-arg to point to the replacement jar
        
        // Run unstash within app directory
        sh "echo 'dir on app'"
        dir("app") {
            unstash "app"
        }

        sh "echo contents of app dir..."
        sh "ls -la ${pwd()}/output/*"

        def custom_app_image = docker.build("springboot", "--build-arg JAR_FILE=./output/app.jar -f spring-boot-demo/Dockerfile .") 
    }

    stage ('Deploy To Kube') {
        sh 'kubectl create -f /kube/deploy/app_set/sb-demo-deployment.yaml'
    }
    stage('Configure Kube Load Balancer') {
        sh 'kubectl create -f /kube/deploy/app_set/sb-demo-service.yaml'
    }
}