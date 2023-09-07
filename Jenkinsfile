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
    //NEXUS_URL = "3.82.152.7:8081"
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

            nexusArtifactUploader artifacts: 
          [
            [
              artifactId: 'web', 
              classifier: '', 
              file: 'target/hello-world.war', 
              type: 'war'
              ]
            ], 
            credentialsId: 'nexus-jenkins', 
            groupId: 'web', 
            nexusUrl: '100.25.37.16:8081', 
            nexusVersion: 'nexus3', 
            protocol: 'http', 
            repository: nexusRepo, 
            version: "${readPomVersion.version}"
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

