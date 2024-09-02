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
                sh 'npm install'
            }
        }
        
        stage('Build Application') {
            steps {
                sh 'npm run build'
            }
        }
        
        stage('Run Tests') {
            steps {
                sh 'npm test'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    myimage = docker.build("sethu904/reactapp:${env.BUILD_ID}")
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
                sh 'sed -i "s/tagversion/${env.BUILD_ID}/g" serviceLB.yaml'
                sh 'sed -i "s/tagversion/${env.BUILD_ID}/g" deployment.yaml'
                step([$class: 'KubernetesEngineBuilder', projectId: env.PROJECT_ID, clusterName: env.CLUSTER_NAME, location: env.LOCATION, manifestPattern: 'serviceLB.yaml', credentialsId: env.CREDENTIALS_ID, verifyDeployments: true])
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
