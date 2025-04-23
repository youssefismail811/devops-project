pipeline {
    agent any

    environment {
        VAULT_ADDR = 'http://13.57.42.215:8200'
        AWS_REGION = 'us-west-1'
        ECR_REPO = 'devops-ecr-repo'
        IMAGE_TAG = 'latest'
        ACCOUNT_ID = '646304591001'
        HELM_VERSION = '3.12.0'  // Added Helm version
        NAMESPACE = 'default'    // Added namespace
    }

    stages {
        stage('Verify Files') {
            steps {
                sh 'ls -la'
            }
        }
        
        stage('Build & Push Docker Image') {
            steps {
                withVault(
                    vaultSecrets: [[
                        path: 'jenkins/aws',
                        secretValues: [
                            [envVar: 'AWS_ACCESS_KEY_ID', vaultKey: 'access_key'],
                            [envVar: 'AWS_SECRET_ACCESS_KEY', vaultKey: 'secret_key']
                        ]
                    ]],
                    configuration: [
                        vaultCredentialId: 'jenkins-vault',
                        vaultUrl: "${env.VAULT_ADDR}"
                    ]
                ) {
                    sh '''
                        echo "=== Logging in to AWS ECR ==="
                        aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                        aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                        aws ecr get-login-password --region $AWS_REGION | \
                        docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

                        echo "=== Building Docker image ==="
                        docker build -t $ECR_REPO:$IMAGE_TAG .

                        echo "=== Tagging image ==="
                        docker tag $ECR_REPO:$IMAGE_TAG $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG

                        echo "=== Pushing image to ECR ==="
                        docker push $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG
                        
                        echo "=== Cleanup ==="
                        docker rmi $ECR_REPO:$IMAGE_TAG
                        docker rmi $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG
                    '''
                }
            }
        }

       stage('Install Helm') {
        steps {
          sh '''
            # Download and install Helm without sudo
            curl -fsSL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar -xz -C /tmp
            mkdir -p ${HOME}/bin
            mv /tmp/linux-amd64/helm ${HOME}/bin/helm
            chmod +x ${HOME}/bin/helm
            export PATH="${HOME}/bin:${PATH}"
            helm version
          '''
    }
}
        

        stage('Deploy Application') {
            steps {
                dir('helm') {
                    sh '''
                        helm upgrade --install my-app . \
                            --namespace ${NAMESPACE} \
                            --set image.repository=${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO} \
                            --set image.tag=${IMAGE_TAG} \
                            --atomic \
                            --timeout 5m \
                            --wait
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    helm status my-app -n ${NAMESPACE}
                    kubectl get pods -n ${NAMESPACE}
                    kubectl get svc -n ${NAMESPACE}
                '''
            }
        }
    }

    post {
        always {
            cleanWs()
            sh '''
                echo "=== Cleanup Docker images ==="
                docker system prune -f || true
            '''
        }
        success {
            echo 'Pipeline completed successfully'
        }
        failure {
            echo 'Pipeline failed'
            sh 'helm rollback my-app 0 -n ${NAMESPACE} || true'
        }
    }
}