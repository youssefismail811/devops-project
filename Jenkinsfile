pipeline {
    agent any
    environment {
        VAULT_ADDR = 'http://13.57.42.215:8200'
        AWS_REGION = 'us-west-1'
        ECR_REPO = 'devops-ecr-repo'
        IMAGE_TAG = 'latest'
        ACCOUNT_ID = '646304591001'
        HELM_VERSION = '3.12.0'
        NAMESPACE = 'default'
        KUBECONFIG = credentials('kubeconfig')  // Add your kubeconfig credential ID
        PATH = "${env.HOME}/bin:${env.PATH}"
    }

    stages {
        stage('Verify Cluster Access') {
            steps {
                sh '''
                    echo "=== Verifying Kubernetes Access ==="
                    kubectl cluster-info
                    kubectl get ns
                '''
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
                    '''
                }
            }
        }

        stage('Install Helm') {
            steps {
                sh '''
                    echo "=== Installing Helm ==="
                    mkdir -p ${HOME}/bin
                    curl -fsSL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar -xz -C /tmp
                    mv /tmp/linux-amd64/helm ${HOME}/bin/helm
                    chmod +x ${HOME}/bin/helm
                    helm version
                '''
            }
        }

        stage('Deploy Application') {
            steps {
                dir('helm') {
                    sh '''
                        echo "=== Deploying with Helm ==="
                        export KUBECONFIG=${KUBECONFIG}
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
                    echo "=== Verifying Deployment ==="
                    export KUBECONFIG=${KUBECONFIG}
                    helm status my-app -n ${NAMESPACE}
                    kubectl get pods -n ${NAMESPACE}
                    kubectl get svc -n ${NAMESPACE}
                '''
            }
        }
    }

    post {
        always {
            node {
                cleanWs()
                sh '''
                    echo "=== Cleaning up Docker ==="
                    docker rmi ${ECR_REPO}:${IMAGE_TAG} || true
                    docker rmi ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG} || true
                    docker system prune -f || true
                '''
            }
        }
        failure {
            node {
                sh '''
                    echo "=== Attempting Rollback ==="
                    export KUBECONFIG=${KUBECONFIG}
                    helm rollback my-app 0 -n ${NAMESPACE} || true
                    echo "=== Cluster Status ==="
                    kubectl get all -n ${NAMESPACE} || true
                '''
            }
        }
    }
}
