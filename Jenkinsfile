pipeline {
    agent any

    environment {
        IMAGE_NAME = 'hungcode68/dockertest'             // tên Docker image
        IMAGE_TAG = 'latest'                             // tag cho image
        CONTAINER_NAME = 'javawebapp_container'          // tên container
        DOCKERHUB_CREDENTIALS = 'dockerhub-creds'        // ID credentials Docker Hub trong Jenkins
    }

    stages {
        stage('Build WAR with Ant') {
            steps {
                echo '🔧 Building WAR using Ant...'
                bat 'ant clean'
                bat 'ant -f build.xml dist'   // target 'dist' sẽ tạo file war trong thư mục dist/
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                script {
                    docker.build("${IMAGE_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Stop Previous Container') {
            steps {
                echo '🛑 Stopping previous container if exists...'
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
                echo '🚀 Running new Docker container...'
                bat "docker run -d --name ${CONTAINER_NAME} -p 8081:8081 ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo '📦 Pushing Docker image to Docker Hub...'
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
