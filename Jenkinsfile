pipeline {
    agent any

    environment {
        SONARQUBE = 'sonarqube' // اسم SonarQube الذي قمت بتخزينه في Jenkins
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                script {
                    // تثبيت الاعتماديات باستخدام Composer
                    sh 'composer install'
                }
            }
        }

        stage('Run PHPUnit Tests') {
            steps {
                script {
                    // تشغيل PHPUnit وإنشاء تقرير التغطية
                    sh './vendor/bin/phpunit --coverage-clover build/coverage/clover.xml'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    // إرسال تقرير التغطية إلى SonarQube
                    withSonarQubeEnv('sonarqube') {
                        sh 'mvn sonar:sonar -Dsonar.php.coverage.reportPaths=build/coverage/clover.xml'
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    // انتظار تحليل SonarQube للحصول على تقرير جودة الكود
                    waitForQualityGate()
                }
            }
        }
    }
}
