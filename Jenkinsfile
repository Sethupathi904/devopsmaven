pipeline {
    agent any

    environment {
        PROJECT_ID = 'groovy-legacy-434014-d0'
        CLUSTER_NAME = 'k8s-cluster'
        LOCATION = 'us-central1-c'
        CREDENTIALS_ID = 'kubernetes'
        PATH = "/usr/local/bin:${env.PATH}"
    }
    
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        
        stage('Install Dependencies') {
            steps {
                dir('path/to/react-app') { // Change this to the correct path if needed
                    sh 'npm install'
                }
            }
        }
        
        stage('Build Application') {
            steps {
                dir('path/to/react-app') { // Change this to the correct path if needed
                    sh 'npm run build'
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    myimage = docker.build("sethu904/reactapp:${env.BUILD_ID}", "path/to/react-app") // Adjust path if needed
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'dockerhub', variable: 'dockerhub')]) {
                        sh "docker login -u sethu904 -p ${dockerhub}"
                    }
                    myimage.push("${env.BUILD_ID}")
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                echo "Deploying to Kubernetes..."
                sh 'sed -i "s/tagversion/${env.BUILD_ID}/g" deployment.yaml'
                sh 'sed -i "s/tagversion/${env.BUILD_ID}/g" service_loadbalancer.yaml'
                step([$class: 'KubernetesEngineBuilder', projectId: env.PROJECT_ID, clusterName: env.CLUSTER_NAME, location: env.LOCATION, manifestPattern: 'service_loadbalancer.yaml', credentialsId: env.CREDENTIALS_ID, verifyDeployments: true])
                step([$class: 'KubernetesEngineBuilder', projectId: env.PROJECT_ID, clusterName: env.CLUSTER_NAME, location: env.LOCATION, manifestPattern: 'deployment.yaml', credentialsId: env.CREDENTIALS_ID, verifyDeployments: true])
                echo "Deployment completed."
            }
        }
    }
    
    post {
        success {
            echo "Pipeline completed successfully."
        }
        failure {
            echo "Pipeline failed."
        }
    }
}
