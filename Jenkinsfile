
pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'dockervibh'
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

        stage('Deploy Locally') {
            steps {
                withCredentials([file(
                    credentialsId: 'backend-env-file',
                    variable: 'BACKEND_ENV'
                )]) {
                    sh '''
                        cp "$BACKEND_ENV" backend/.env
                        trap 'rm -f backend/.env' EXIT

                        docker compose -p idevifyapp pull
                        docker compose -p idevifyapp up -d --no-build
                    '''
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }
    }
}
