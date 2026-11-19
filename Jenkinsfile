pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'dockervibh'
        DOCKER_CREDENTIALS = 'dockerhub-credentials'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Backend') {
            steps {
                sh 'docker build -t idevify-backend ./backend'
            }
        }

        stage('Build Frontend') {
            steps {
                sh 'docker build -t idevify-frontend ./frontend'
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_TOKEN'
                )]) {
                    sh 'echo "$DOCKER_TOKEN" | docker login -u "$DOCKER_USER" --password-stdin'
                }
            }
        }

        stage('Push Images') {
            steps {
                sh '''
                    docker tag idevify-backend $DOCKERHUB_USER/idevify-backend:latest
                    docker tag idevify-frontend $DOCKERHUB_USER/idevify-frontend:latest
                    docker push $DOCKERHUB_USER/idevify-backend:latest
                    docker push $DOCKERHUB_USER/idevify-frontend:latest
                '''
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }
    }
}