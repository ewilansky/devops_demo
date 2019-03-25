node() {
    stage('Checkout') {
        checkout scm
    }
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
    }

    stage('Retrieve App') {
        withCredentials([usernamePassword(credentialsId: 'nexus', usernameVariable: 'NEXUS_USR', passwordVariable: 'NEXUS_PASSWORD')]) {   
            script {
                def user = "$NEXUS_USR:$NEXUS_PASSWORD"
                def apiBase = "http://package-repo:8081/service/rest/v1/search/assets/download"
                def artifactMd5Hash = "1373ba65e2f2845af90e479e4bf7f40b"
                def group = "org.ahl.springbootdemo"
                def name = "spring-boot-demo"
                def repository="maven-public"
                
                def retrieveUrl = "${apiBase}?repository=${repository}&maven.groupId=${group}&maven.artifactId=${name}&maven.extension=jar&md5=${artifactMd5Hash}"

                downloadArtifact("${user}", "${retrieveUrl}")
            }
        }
        // stash for retrieval during image build
        stash name: 'app', includes: 'output/*'
    }

    stage('App Image Build') {
        // NOTE: When building a different application, simply change the build-arg to point to the replacement jar
        
        sh "echo current dir in Jenkins container"
        sh "ls -la ."

        sh "echo contents of /home/project is spring-boot-demo volume projection"
        sh "ls -la /home/project/"

        // currently in the Jenkins workspace in the Jenkins container
        def custom_app_image = docker.build("springboot", "--build-arg JAR_FILE=./output/app.jar -f /home/project/Dockerfile .") 
    }

    stage ('Deploy To Kube') {
        sh 'kubectl create -f /kube/deploy/app_set/sb-demo-deployment.yaml'
    }
    stage('Configure Kube Load Balancer') {
        sh 'kubectl create -f /kube/deploy/app_set/sb-demo-service.yaml'
    }
}

def downloadArtifact(String user, String url) {
  def newUrl = url
  def newUser = user
  echo ("url is $newUrl")
  echo ("user is: $newUser")
  echo("Downloading artifact from Nexus:")
  sh(returnStdout: true, script: """  mkdir -p output
  curl -L -u ${newUser} -X GET "${newUrl}" --output ./output/app.jar
  ls -la""")
}