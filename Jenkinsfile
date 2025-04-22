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
    stage('Build Application') {
      steps {
        sh 'mvn clean package' 
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
            echo "Logging in to AWS ECR..."
            aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
            aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY

            aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

            echo "Building Docker image..."
            docker build -t $ECR_REPO:$IMAGE_TAG .

            echo "Tagging image..."
            docker tag $ECR_REPO:$IMAGE_TAG $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG

            echo "Pushing image to ECR..."
            docker push $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG
          '''
        }
      }
    }
  }
}
