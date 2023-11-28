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
                    sh "${scannerHome}/bin/sonar-scanner --version"
                }
            }
        }
    }
}
