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
    stage('Integrated Test'){
        steps {
          sh 'mvn test'
        }
        post {
                success {
                    slackSend channel: '#general',
                    color: 'good',
                    message: "INTEGRATED TESTING IS SUCCESS"
                }
                failure {
                    slackSend channel: '#general',
                    color: 'danger',
                    message: "INTEGRATED TESTING IS FAILED"
                }
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
          waitForQualityGate abortPipeline: true
          }
       }
    }
    stage('Docker image Build'){
      steps{
        script{
          sh 'docker image build -t $JOB_NAME:v1.$BUILD_ID .'
          sh 'docker image tag $JOB_NAME:v1.$BUILD_ID abionaraji/$JOB_NAME:v1.$BUILD_ID'
          sh 'docker image tag $JOB_NAME:v1.$BUILD_ID abionaraji/$JOB_NAME:latest'
        }
      }
    }
    stage('Push Image To Docker'){
      steps{
        script{
          withCredentials([string(credentialsId: 'dockerhub', variable: 'docker')]) {
            sh 'docker login -u abionaraji -p ${docker}'
            sh 'docker image push abionaraji/$JOB_NAME:v1.$BUILD_ID'
            sh 'docker image push abionaraji/$JOB_NAME:latest'
          }
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

