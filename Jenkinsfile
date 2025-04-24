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
        EKS_CLUSTER_NAME = 'eks'
        PATH = "${env.HOME}/bin:${env.PATH}"
    }

    stages {
        stage('Verify Files') {
            steps {
                sh 'ls -la'
            }
        }

        stage('Configure Kubeconfig') {
            steps {
                sh '''
                    echo "=== Setting up kubeconfig ==="
                    aws eks --region $AWS_REGION update-kubeconfig --name $EKS_CLUSTER_NAME
                '''
            }
        }

        stage('Install Dependencies') {
            steps {
                echo "=== Installing PHP Dependencies with Composer ==="
                sh 'composer install'
            }
        }

        stage('Unit Tests') {
            steps {
                echo "=== Running PHP Unit Tests ==="
                sh './vendor/bin/phpunit tests'
            }
        }

        stage('SonarQube Scan') {
            environment {
                SONARQUBE_SCANNER_HOME = tool 'sonarscanner'
            }
            steps {
                withSonarQubeEnv('sonarqube') {
                    withCredentials([string(credentialsId: 'jenkins-integration', variable: 'SONAR_AUTH_TOKEN')]) {
                        sh '''
                            echo "=== Running SonarQube Scan ==="
                            ${SONARQUBE_SCANNER_HOME}/bin/sonar-scanner \
                              -Dsonar.projectKey=devops-project \
                              -Dsonar.sources=. \
                              -Dsonar.host.url=$SONAR_HOST_URL \
                              -Dsonar.token=$SONAR_AUTH_TOKEN \
                              -Dsonar.php.coverage.reportPaths=build/coverage/clover.xml
                        '''
                    }
                }
            }
        }

        // تعطيل بناء ودفع Docker Image
        // stage('Build & Push Docker Image') {
        //     steps {
        //         ...
        //     }
        // }

        // تعطيل نشر التطبيق
        // stage('Deploy Application') {
        //     steps {
        //         ...
        //     }
        // }

        stage('Verify Deployment') {
            steps {
                echo "=== Skipping Deployment Verification as no push occurred ==="
            }
        }
    }

    post {
        always {
            cleanWs()
            sh '''
                echo "=== Cleaning up Docker ==="
                docker system prune -f || true
            '''
        }
        failure {
            echo "=== Skipping rollback as no deployment occurred ==="
        }
    }
}
