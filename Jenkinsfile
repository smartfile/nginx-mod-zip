pipeline {
    agent { label 'amazon-t2.micro' }

    options {
        timeout(time: 20, unit: 'MINUTES')
    }
    stages {
        stage('Start') {
            steps {
                slackSend(color: 'warning', message: "Started: ${env.JOB_NAME} #${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)")
            }
        }
        stage('Build') {
            steps {
                sh 'sudo make build'
            }
        }
    post {
        success {
            slackSend(color: 'good', message: "Success: ${env.JOB_NAME} #${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)")
        }
        failure {
            slackSend(color: 'danger', message: "Failure: ${env.JOB_NAME} #${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)")
        }
        cleanup {
            cleanWs externalDelete: 'sudo shutdown --no-wall --poweroff now || echo "Shutdown"', notFailBuild: true
        }
    }
}