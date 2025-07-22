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
            rem Xoá và tạo thư mục build mới
            if exist build rmdir /s /q build
            mkdir build\\classes
            mkdir build\\warcontent

            rem Biên dịch mã nguồn Java
            javac -d build\\classes -cp "%TOMCAT_PATH%\\lib\\servlet-api.jar" ^
                src\\*.java

            rem Copy toàn bộ nội dung Web Pages vào warcontent
            xcopy "Web Pages\\*" build\\warcontent /E /I /Y

            rem Copy class đã biên dịch vào WEB-INF/classes
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
        echo '🚀 Deploying WAR to Tomcat...'
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
            def containerExists = bat(
                script: "docker ps -a -q -f name=${CONTAINER_NAME}",
                returnStdout: true
            ).trim()

            if (containerExists) {
                bat "docker stop ${CONTAINER_NAME}"
                bat "docker rm ${CONTAINER_NAME}"
            } else {
                echo "ℹ️ Container ${CONTAINER_NAME} does not exist. Skipping stop/remove step."
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
