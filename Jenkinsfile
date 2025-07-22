pipeline {
    agent any

    environment {
        IMAGE_NAME = 'hungcode68/dockertest'
        IMAGE_TAG = 'latest'
        CONTAINER_NAME = 'javawebapp_container'
        DOCKERHUB_CREDENTIALS = 'dockerhub-creds'
    }

    stages {
        stage('Build WAR') {
            steps {
                echo '📦 Building WAR file manually using jar...'
                bat '''
                    if exist build (
                        rmdir /s /q build
                    )
                    mkdir build
                    jar -cvf build/VinfastSystem.war -C WebContent .
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image from WAR...'
                script {
                    docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Stop Previous Container') {
            steps {
                echo '🛑 Stopping and removing previous container if exists...'
                script {
                    def containerExists = bat(
                        script: "docker ps -a -q -f name=${CONTAINER_NAME}",
                        returnStdout: true
                    ).trim()
                    if (containerExists) {
                        bat "docker stop ${CONTAINER_NAME}"
                        bat "docker rm ${CONTAINER_NAME}"
                    }
                }
            }
        }

        stage('Run New Container') {
            steps {
                echo '🚀 Running new container...'
                bat "docker run -d --name ${CONTAINER_NAME} -p 8081:8081 ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo '📦 Pushing image to Docker Hub...'
                script {
                    docker.withRegistry('https://index.docker.io/v1/', DOCKERHUB_CREDENTIALS) {
                        docker.image("${IMAGE_NAME}:${IMAGE_TAG}").push()
                    }
                }
            }
        }
    }

    post {
        success {
            echo '✅ Triển khai Java Web App thành công!'
        }
        failure {
            echo '❌ Có lỗi xảy ra trong pipeline!'
        }
    }
}
