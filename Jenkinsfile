pipeline {
    agent any

    environment {
        IMAGE_NAME = 'hungcode68/dockertest'        // Tên Docker image bạn muốn push
        IMAGE_TAG = 'latest'
        CONTAINER_NAME = 'javawebapp_container'     // Tên container
        DOCKERHUB_CREDENTIALS = 'dockerhub-creds'   // ID credentials trong Jenkins
    }

    stages {
        stage('Build WAR') {
            steps {
                bat 'mvn clean package' // Nếu bạn dùng Maven để tạo file .war
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
            echo '✅ Triển khai Java Web App thành công tại http://localhost:8081'
        }
        failure {
            echo '❌ Có lỗi xảy ra trong pipeline!'
        }
    }
}
