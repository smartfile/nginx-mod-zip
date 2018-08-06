pipeline {
    agent { label 'amazon-t2.micro' }

    environment {
        NGINXVERSION = '1.12.2'
    }
    options {
        timeout(time: 20, unit: 'MINUTES')
    }
    stages {
        stage('Start') {
            steps {
                slackSend(color: 'warning', message: "Started: ${env.JOB_NAME} #${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)")
                git branch: '${env.BRANCH_NAME}', credentialsId: 'f762be77-3885-42c6-9f4e-2075c4c5c1c9', url: 'git@github.com:smartfile/nginx-mod-zip.git'
            }
        }
        stage('Build') {
            steps {
                sh 'sudo docker build --build-arg nginx_version=$NGINXVERSION --tag nginx-mod-zip .'
                sh 'sudo docker run -dit nginx-mod-zip bash'
                sh 'sudo docker cp $(sudo docker ps -q):/nginxzip-$NGINXVERSION-1.x86_64.rpm .'
            }
        }
        stage('Publish') {
            when {
                branch 'jenkinsandcentos7building'
            }
            sh 'git add .'
            sh 'git tag -a tagName -m "Your tag comment"'
            sh 'git commit -am "commit message"'
            sh 'git push origin jenkinsandcentos7building'
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