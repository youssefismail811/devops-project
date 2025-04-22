pipeline {
  agent any

  environment {
    VAULT_ADDR = 'http://13.57.42.215/:8200'
  }

  stages {
    stage('Read secrets from Vault') {
      steps {
        withVault([ 
          vaultSecrets: [
            [path: 'secret/jenkins/aws', secretValues: [
              [envVar: 'access_key', vaultKey: 'access_key'],
              [envVar: 'secret_key', vaultKey: 'secret_key']
            ]]
          ],
          vaultCredentialId: 'jenkins-vault',
        ]) {
          sh '''
            echo "Access Key: ${access_key}"
            echo "Secret Key: ${secret_key}"
          '''
        }
      }
    }
  }
}
