pipeline {
    agent any

    environment {
        IMAGE_NAME = 'hungcode68/dockertest'
        IMAGE_TAG = 'latest'
        CONTAINER_NAME = 'javawebapp_container'
        DOCKERHUB_CREDENTIALS = 'dockerhub-creds'
        TOMCAT_PATH = 'C:\\apache-tomcat-10.1.41'
    }

    stages {
        stage('Build WAR') {
            steps {
                echo '📦 Compiling and packaging WAR file...'
                bat '''
                    rem Xoá thư mục build cũ nếu có
                    if exist build rmdir /s /q build
                    mkdir build\\classes
                    mkdir build\\warcontent

                    rem Biên dịch từng file .java trong src
                    for %%f in (src\\*.java) do (
                        javac -d build\\classes -cp "%TOMCAT_PATH%\\lib\\servlet-api.jar" %%f
                    )

                    rem Copy Web Pages vào warcontent (nếu tồn tại)
                    if exist "Web Pages" (
                        xcopy "Web Pages\\*" build\\warcontent /E /I /Y
                    )

                    rem Tạo thư mục WEB-INF/classes và copy class đã biên dịch
                    mkdir build\\warcontent\\WEB-INF\\classes
                    xcopy build\\classes\\* build\\warcontent\\WEB-INF\\classes /E /I /Y

                    rem Đóng gói file WAR
                    cd build\\warcontent
                    jar -cvf ..\\WebApplication.war *
                    cd ..\\..
                '''
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                echo '🚀 Deploying WAR to Tomcat (local test only)...'
                bat '''
                    if not exist "%TOMCAT_PATH%\\webapps" (
                        echo "Tomcat webapps folder not found!"
                        exit /b 1
                    )
                    copy build\\WebApplication.war "%TOMCAT_PATH%\\webapps\\" /Y
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
                    def containerId = bat(
                        script: "docker ps -aq -f name=${CONTAINER_NAME}",
                        returnStdout: true
                    ).trim()

                    if (containerId) {
                        bat "docker stop ${CONTAINER_NAME} || exit 0"
                        bat "docker rm ${CONTAINER_NAME} || exit 0"
                        echo "✅ Container ${CONTAINER_NAME} stopped and removed."
                    } else {
                        echo "ℹ️ No existing container found. Skipping."
                    }
                }
            }
        }

        stage('Run New Container') {
            steps {
                echo '🚀 Running new container on port 8085...'
                script {
                    def portInUse = bat(
                        script: 'netstat -ano | findstr :8085',
                        returnStatus: true
                    ) == 0

                    if (portInUse) {
                        error "❌ Port 8085 is already in use. Please free the port before retrying."
                    }

                    bat "docker run -d --name ${CONTAINER_NAME} -p 8085:8085 ${IMAGE_NAME}:${IMAGE_TAG}"
                }
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
            echo '✅ Triển khai Java Web App thành công trên port 8085!'
        }
        failure {
            echo '❌ Có lỗi xảy ra trong quá trình triển khai!'
        }
    }
}
