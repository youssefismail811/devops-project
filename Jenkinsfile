pipeline {
  agent any

  environment {
    VAULT_ADDR = 'http://13.57.42.215/:8200' 
  }
  stages {
    stage('Fetch AWS Secrets from Vault') {
      steps {
        withVault(
          vaultSecrets: [
            [path: 'secret/data/jenkins/aws', secretValues: [
              [envVar: 'AWS_ACCESS_KEY', vaultKey: 'access_key'],
              [envVar: 'AWS_SECRET_KEY', vaultKey: 'secret_key']
            ]]
          ],
          vaultAddr: "${env.VAULT_ADDR}",
          vaultCredentialId: 'jenkins-vault' 
        ) {
          sh '''
            echo "AWS_ACCESS_KEY: $AWS_ACCESS_KEY"
            echo "AWS_SECRET_KEY: $AWS_SECRET_KEY"
          '''
        }
      }
    }
  }
}
