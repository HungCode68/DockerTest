pipeline {
    agent any

    environment {
        IMAGE_NAME = 'hungcode68/dockertest'   // Thay bằng tên Docker Hub của bạn
        IMAGE_TAG = 'latest'
        CONTAINER_NAME = 'javawebapp_container'
        DOCKERHUB_CREDENTIALS = 'dockerhub-creds' // ID đã tạo trong Jenkins Credentials
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/HungCode68/DockerTest.git'
            }
        }

        stage('Build WAR') {
            steps {
                bat 'mvn clean package'  // Nếu dùng Maven
                // Hoặc: bat 'gradlew build' nếu dùng Gradle
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
                    def containerExists = sh(
                        script: "docker ps -a -q -f name=${CONTAINER_NAME}",
                        returnStdout: true
                    ).trim()
                    if (containerExists) {
                        sh "docker stop ${CONTAINER_NAME}"
                        sh "docker rm ${CONTAINER_NAME}"
                    }
                }
            }
        }

        stage('Run New Container') {
            steps {
                sh "docker run -d --name ${CONTAINER_NAME} -p 8081:8081 ${IMAGE_NAME}:${IMAGE_TAG}"
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
            echo 'Triển khai Java Web App thành công!'
        }
        failure {
            echo 'Có lỗi xảy ra trong pipeline!'
        }
    }
}
