pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'dockerhub'
        DOCKER_IMAGE = 'sethu904/my-react-app'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build(DOCKER_IMAGE)
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "Push Docker Image"
                    withCredentials([string(credentialsId: DOCKER_CREDENTIALS_ID, variable: 'dockerhub')]) {
                        sh "docker login -u sethu904 -p ${dockerhub}"
                        docker.image(DOCKER_IMAGE).push("${env.BUILD_ID}")
                    }
                }
            }
        }
    }

    post {
        success {
            emailext (
                to: 'your-email@example.com',
                subject: 'Build Successful: ${JOB_NAME} ${BUILD_NUMBER}',
                body: 'The build was successful.'
            )
        }
        failure {
            emailext (
                to: 'your-email@example.com',
                subject: 'Build Failed: ${JOB_NAME} ${BUILD_NUMBER}',
                body: 'The build failed.'
            )
        }
    }
}
