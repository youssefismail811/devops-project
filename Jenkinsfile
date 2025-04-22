pipeline {
  agent any

  environment {
    VAULT_ADDR = 'http://13.57.42.215:8200'
    AWS_REGION = 'us-west-1'
    ECR_REPO = 'devops-ecr-repo'
    IMAGE_TAG = 'latest'
    ACCOUNT_ID = '646304591001'
  }

    stages {

        stage('Unit Tests') {
            steps {
                sh 'vendor/bin/phpunit || true'
            }
        }

        stage('SonarQube Analysis') {
            environment {
                SONAR_TOKEN = credentials('sonar-token')
            }
            steps {
                withSonarQubeEnv("${SONARQUBE_SERVER}") {
                    sh '''
                    sonar-scanner \
                      -Dsonar.projectKey=php-devops \
                      -Dsonar.sources=. \
                      -Dsonar.host.url=$SONAR_HOST_URL \
                      -Dsonar.login=$SONAR_TOKEN
                    '''
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Configure VAULT & Push to ECR') {
            steps {
                withVault(
                    vaultSecrets: [[
                        path: "${VAULT_SECRET_PATH}",
                        secretValues: [
                            [envVar: 'AWS_ACCESS_KEY_ID', vaultKey: 'aws_access_key'],
                            [envVar: 'AWS_SECRET_ACCESS_KEY', vaultKey: 'aws_secret_key']
                        ]
                    ]],
                    
                ) {
                    sh '''
                    echo "Logging in to ECR..."
                    aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO
                    docker tag $DOCKER_IMAGE:latest $ECR_REPO:latest
                    docker push $ECR_REPO:latest
                    
                    '''
                }
            }
        }

        stage('Deploy to Dev') {
            steps {
                sh '''
                aws eks update-kubeconfig --region $AWS_REGION --name eks
                helm upgrade --install php-devops-dev ./helm \
                    --namespace dev \
                    --create-namespace \
                    -f ./helm/values-dev.yaml
                '''
            }
        }

        stage('Deploy to Staging') {
            steps {
                input message: "Approve deployment to Staging?"
                sh '''
                helm upgrade --install php-devops-staging ./helm \
                    --namespace staging \
                    --create-namespace \
                    -f ./helm/values-staging.yaml
                '''
            }
        }

        stage('Deploy to Prod') {
            steps {
                input message: "Approve deployment to Production?"
                sh '''
                helm upgrade --install php-devops-prod ./helm \
                    --namespace prod \
                    --create-namespace \
                    -f ./helm/values-prod.yaml
                '''
            }
        }
        



    }

    post {
        always {
            cleanWs()
        }
    }
}