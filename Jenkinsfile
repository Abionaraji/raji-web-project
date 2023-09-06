def COLOR_MAP = [
    'SUCCESS': 'good', 
    'FAILURE': 'danger',
    'UNSTABLE': 'danger'
]
pipeline {
  agent any
  tools {
    maven 'Maven'
    jdk 'JDK'
  }
   environment {
    WORKSPACE = "${env.WORKSPACE}"
    NEXUS_CREDENTIAL_ID = 'nexus-jenkins'
    //NEXUS_USER = "$admin"
    //NEXUS_PASSWORD = "$admin"
    //NEXUS_URL = "100.25.30.222:8081"
    //NEXUS_REPOSITORY = "vpro-maven"
    //NEXUS_REPO_ID    = "maven_project"
    //ARTVERSION = "${env.BUILD_ID}"
  }
  stages {
    stage('Git Checkout'){
            steps{
                git branch: 'main', url: 'https://github.com/Abionaraji/raji-web-project.git'
            }
        }
    stage('Build') {
      steps {
        sh 'mvn clean package'
      }
      post {
        success {
          echo ' now Archiving '
          archiveArtifacts artifacts: '**/*.war'
        }
      }
    }
    stage('Unit Test'){
        steps {
            sh 'mvn test'
        }
    }
    stage('Integration Test'){
        steps {
          sh 'mvn verify -DskipUnitTests'
        }
    }
    stage ('Checkstyle Code Analysis'){
        steps {
            sh 'mvn checkstyle:checkstyle'
        }
    }
    stage('Sonar Scanner'){
            steps{
                withSonarQubeEnv(credentialsId: 'sonar-jenkins', installationName: 'SonarQube') {
                    sh 'mvn sonar:sonar'
                }
            }
        }
    stage('SonarQube GateKeeper') {
        steps {
          timeout(time : 1, unit : 'HOURS'){
          waitForQualityGate abortPipeline: false
          }
       }
    }
    stage("Nexus Artifact Uploader"){
        steps{
           script{
            
            def readPomVersion = readMavenPom file: 'pom.xml'

            def nexusRepo = readPomVersion.version.endsWith("SNAPSHOT") ? "vpro-snapshot" : "vpro-maven"

            nexusArtifactUploader(
              nexusVersion: 'nexus3',
              protocol: 'http',
              nexusUrl: '100.25.30.222:8081',
              groupId: 'com.njonecompany.web',
              version: "${readPomVersion.version}",
              repository: nexusRepo,
              credentialsId: 'nexus-jenkins',
              artifacts: [
                  [artifactId: 'web',
                  classifier: '',
                  file: 'target/hello-world.war',
                  type: 'war']
              ]
            )
           }
        }
    }
    stage('Docker Image Build'){
      steps{
        script{
          sh 'docker image build -t $JOB_NAME:v1.$BUILD_ID .'
          sh 'docker image tag $JOB_NAME:v1.$BUILD_ID abionaraji/$JOB_NAME:v1.$BUILD_ID'
          sh 'docker image tag $JOB_NAME:v1.$BUILD_ID abionaraji/$JOB_NAME:latest'
        }
      }
    }
 }
  post {
    always {
        echo 'Slack Notifications.'
        slackSend channel: '#general', //update and provide your channel name
        color: COLOR_MAP[currentBuild.currentResult],
        message: "*${currentBuild.currentResult}:* Job Name '${env.JOB_NAME}' build ${env.BUILD_NUMBER} \n Build Timestamp: ${env.BUILD_TIMESTAMP} \n Project Workspace: ${env.WORKSPACE} \n More info at: ${env.BUILD_URL}"
    }
  }
}

