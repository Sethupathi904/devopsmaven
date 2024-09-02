pipeline {
    agent any
    
    environment {
        PROJECT_ID = 'groovy-legacy-434014-d0'
        CLUSTER_NAME = 'k8s-cluster'
        LOCATION = 'us-central1-c'
        CREDENTIALS_ID = 'kubernetes'
    }
    
    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }
        
        stage('Install Dependencies') {
            steps {
                dir('my-react-app') {
                    sh 'npm install'
                }
            }
        }
        
        stage('Build Application') {
            steps {
                dir('my-react-app') {
                    sh 'npm run build'
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    def myimage = docker.build("sethu904/devops:${env.BUILD_ID}", "-f Dockerfile .")
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'dockerhub', variable: 'dockerhub')]) {
                        sh "docker login -u sethu904 -p ${dockerhub}"
                        sh "docker push sethu904/devops:${env.BUILD_ID}"
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh "sed -i 's/tagversion/${env.BUILD_ID}/g' deployment.yaml"
                    sh "sed -i 's/tagversion/${env.BUILD_ID}/g' serviceLB.yaml"
                    
                    step([$class: 'KubernetesEngineBuilder', 
                        projectId: env.PROJECT_ID, 
                        clusterName: env.CLUSTER_NAME, 
                        location: env.LOCATION, 
                        manifestPattern: 'deployment.yaml', 
                        credentialsId: env.CREDENTIALS_ID, 
                        verifyDeployments: true])
                    
                    step([$class: 'KubernetesEngineBuilder', 
                        projectId: env.PROJECT_ID, 
                        clusterName: env.CLUSTER_NAME, 
                        location: env.LOCATION, 
                        manifestPattern: 'serviceLB.yaml', 
                        credentialsId: env.CREDENTIALS_ID, 
                        verifyDeployments: true])
                }
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
