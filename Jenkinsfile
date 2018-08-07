pipeline {
    agent { 
        label 'amazon-t2.micro'
    }
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
                echo "branch name is ${env.BRANCH_NAME}"
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
                branch 'master'
            }
            steps {
                withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: '9ebe9120-03fc-4911-8957-6a9dfe070e96', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD']]) {
                    sh 'git remote set-url origin https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/smartfile/nginx-mod-zip.git'
                    sh 'git add .'
                    sh 'git commit -am \"commit message\"'
                    sh 'git status'
                    sh 'git tag -a tagName -m "Your tag comment"'
                    sh 'git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/smartfile/nginx-mod-zip.git jenkinsandcentos7building'
                }
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