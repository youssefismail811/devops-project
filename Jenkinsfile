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
    stage('Read secrets from Vault') {
      steps {
        withVault(
          vaultSecrets: [[
            path: 'jenkins/aws',
            secretValues: [
              [envVar: 'access_key', vaultKey: 'access_key'],
              [envVar: 'secret_key', vaultKey: 'secret_key']
            ]
          ]],
          configuration: [
            vaultCredentialId: 'jenkins-vault',
            vaultUrl: "${env.VAULT_ADDR}"
          ]
        ) {
          sh '''
            echo "Access Key: ${access_key}"
            echo "Secret Key: ${secret_key}"
          '''
        }
      }
    }

    stage('Login to ECR') {
      steps {
        sh '''
          aws configure set aws_access_key_id $access_key
          aws configure set aws_secret_access_key $secret_key
          aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
        '''
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
          docker build -t $ECR_REPO:$IMAGE_TAG .
        '''
      }
    }

    stage('Push to ECR') {
      steps {
        sh '''
          docker tag $ECR_REPO:$IMAGE_TAG $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG
          docker push $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG
        '''
      }
    }
  }
}
