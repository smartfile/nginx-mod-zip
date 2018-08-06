pipeline {
    agent { label 'amazon-t2.micro' }

    environment {
        //global but overridable
        NGINX-VERSION = '1.12.2'
    }
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
                sh 'sudo docker build --build-arg nginx_version=$NGINX-VERSION --tag nginx-mod-zip .'
                sh 'sudo docker run -dit nginx-mod-zip bash'
                sh 'sudo docker cp $(docker ps -q):/nginxzip-$NGINX-VERSION-1.x86_64.rpm .'
            }
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