pipeline {
  agent any

  environment {
    VAULT_ADDR = 'http://13.57.42.215:8200'
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
  }
}
