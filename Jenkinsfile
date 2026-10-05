pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Java') {
            steps {
                sh '''
                    cd java
                    mvn clean package
                '''
            }
        }

        stage('Docker Compose Build') {
            steps {
                sh 'docker compose build'
            }
        }

        stage('Deploy') {
            steps {
                sh 'docker compose up -d'
            }
        }

        stage('Check') {
            steps {
                sh 'docker compose ps'
            }
        }
    }

    post {
        always {
            sh 'docker compose logs --tail=50 || true'
        }
    }
}
