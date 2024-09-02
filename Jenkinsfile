pipeline {
    agent any
    
    environment {
        DOCKER_CREDENTIALS_ID = 'dockerhub'
        DOCKER_IMAGE = "my-react-app:${env.BUILD_ID}"
        PROJECT_ID = 'groovy-legacy-434014-d0'
        CLUSTER_NAME = 'k8s-cluster'
        LOCATION = 'us-central1-c'
        CREDENTIALS_ID = 'kubernetes'
        PATH = "/tmp:$PATH"  // Update to writable directory if necessary
    }
    
    stages {
        stage('Start') {
            steps {
                echo 'Starting pipeline...'
            }
        }
        
        stage('Checkout SCM') {
            steps {
                checkout scm
                sh 'ls -al'  // Verify file existence
            }
        }
        
        stage('Tool Install') {
            steps {
                script {
                    sh 'curl -LO "https://dl.k8s.io/release/v1.27.1/bin/linux/amd64/kubectl"'
                    sh 'chmod +x ./kubectl'
                    sh 'mv ./kubectl /tmp/kubectl'  // Move to a writable directory
                    sh 'export PATH=/tmp:$PATH'    // Update PATH to include the new directory
                }
            }
        }
        
        stage('Build') {
            steps {
                script {
                    sh 'npm install'
                    sh 'npm run build'
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    sh 'npm test'
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    def dockerfile = '''
                    # Dockerfile
                    FROM nginx:alpine
                    COPY build /usr/share/nginx/html
                    EXPOSE 80
                    '''
                    
                    writeFile file: 'Dockerfile', text: dockerfile
                    sh 'docker build -t ${DOCKER_IMAGE} .'
                }
            }
        }
        
        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                        sh 'docker push ${DOCKER_IMAGE}'
                    }
                }
            }
        }
        
        stage('Deploy to K8s') {
            steps {
                script {
                    withCredentials([file(credentialsId: CREDENTIALS_ID, variable: 'KUBE_CONFIG')]) {
                        sh 'gcloud auth activate-service-account --key-file=$KUBE_CONFIG'
                        sh 'gcloud config set project ${PROJECT_ID}'
                        sh 'gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${LOCATION}'
                        
                        def deploymentYaml = '''
                        apiVersion: apps/v1
                        kind: Deployment
                        metadata:
                          name: react-app
                        spec:
                          replicas: 2
                          selector:
                            matchLabels:
                              app: react-app
                          template:
                            metadata:
                              labels:
                                app: react-app
                            spec:
                              containers:
                              - name: react-app
                                image: ${DOCKER_IMAGE}
                                ports:
                                - containerPort: 80
                        '''
                        
                        def serviceYaml = '''
                        apiVersion: v1
                        kind: Service
                        metadata:
                          name: react-app-service
                        spec:
                          selector:
                            app: react-app
                          ports:
                            - protocol: TCP
                              port: 80
                              targetPort: 80
                          type: LoadBalancer
                        '''
                        
                        writeFile file: 'deployment.yaml', text: deploymentYaml
                        writeFile file: 'service.yaml', text: serviceYaml
                        
                        sh 'kubectl apply -f deployment.yaml'
                        sh 'kubectl apply -f service.yaml'
                    }
                }
            }
        }
    }
    
    post {
        success {
            emailext(
                to: 'your-email@example.com',
                subject: 'Build Success',
                body: 'The build and deployment were successful!'
            )
        }
        failure {
            emailext(
                to: 'your-email@example.com',
                subject: 'Build Failure',
                body: 'The build or deployment failed. Please check the logs.'
            )
        }
    }
}
