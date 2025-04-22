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
    stage('Checkout Code') {
      steps {
        git branch: 'main', url: 'https://github.com/youssefismail811/devops-project.git'
      }
    }

    stage('Build with Maven') {
      steps {
        dir('backend') {
          sh 'mvn clean install'
        }
      }
    }

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
          script {
            env.AWS_ACCESS_KEY_ID = access_key
            env.AWS_SECRET_ACCESS_KEY = secret_key
          }

          sh '''
            echo "Access Key: $AWS_ACCESS_KEY_ID"
            echo "Secret Key: $AWS_SECRET_ACCESS_KEY"
          '''
        }
      }
    }

    stage('Login to ECR') {
      steps {
        sh '''
          aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
          aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
          aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
        '''
      }
    }

    stage('Build Docker Image') {
      steps {
        dir('backend') {
          sh '''
            docker build -t $ECR_REPO:$IMAGE_TAG .
          '''
        }
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
