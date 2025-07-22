pipeline {
    agent any

    environment {
        IMAGE_NAME = 'hungcode68/dockertest'
        IMAGE_TAG = 'latest'
        CONTAINER_NAME = 'javawebapp_container'
        DOCKERHUB_CREDENTIALS = 'dockerhub-creds'
    }

    stages {
        stage('Build WAR with Ant') {
            steps {
                bat 'ant clean'
                bat 'ant dist' // hoặc target khác nếu bạn build WAR bằng tên khác
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Stop Previous Container') {
            steps {
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
                bat "docker run -d --name ${CONTAINER_NAME} -p 8081:8081 ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Push to Docker Hub') {
            steps {
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
            echo '✅ Triển khai Java Web App bằng Ant thành công!'
        }
        failure {
            echo '❌ Có lỗi xảy ra trong pipeline!'
        }
    }
}
