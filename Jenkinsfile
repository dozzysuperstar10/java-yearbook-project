pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        EC2_HOST = '18.175.208.124'
        EC2_USER = 'ec2-user'
        PROJECT_DIR = '/home/ec2-user/java-yearbook-project'
        SSH_CREDENTIALS = 'ec2-ssh-key'
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out source code from GitHub...'

                git(
                    branch: 'main',
                    url: 'https://github.com/dozzysuperstar10/java-yearbook-project.git'
                )
            }
        }

        stage('Verify Files') {
            steps {
                echo 'Verifying project files...'

                sh '''
                    set -e

                    test -f docker-compose.yml
                    test -f java/pom.xml
                    test -f java/Dockerfile
                    test -f myportfolio/Dockerfile
                    test -f myportfolio/index.html

                    echo "All required files found."
                '''
            }
        }

        stage('Build Java') {
            steps {
                echo 'Building Java application...'

                dir('java') {
                    sh '''
                        set -e

                        mvn clean package

                        test -s target/yearbook-lambda-1.0.0.jar

                        echo "Java build successful."
                        ls -lh target/yearbook-lambda-1.0.0.jar
                    '''
                }
            }
        }

        stage('Test EC2 SSH') {
            steps {
                echo 'Testing SSH connection to EC2...'

                sshagent(credentials: [env.SSH_CREDENTIALS]) {
                    sh '''
                        set -e

                        ssh \
                            -o StrictHostKeyChecking=no \
                            -o ConnectTimeout=15 \
                            ${EC2_USER}@${EC2_HOST} \
                            "echo 'SSH connection successful'; hostname; whoami"
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application to EC2...'

                sshagent(credentials: [env.SSH_CREDENTIALS]) {
                    sh '''
                        set -e

                        ssh \
                            -o StrictHostKeyChecking=no \
                            -o ConnectTimeout=15 \
                            ${EC2_USER}@${EC2_HOST} \
                            "cd ${PROJECT_DIR} && \
                             git fetch origin main && \
                             git reset --hard origin/main && \
                             docker compose down || true && \
                             docker compose config -q && \
                             docker compose build --no-cache && \
                             docker compose up -d && \
                             docker compose ps"
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Verifying deployed applications...'

                sshagent(credentials: [env.SSH_CREDENTIALS]) {
                    sh '''
                        set -e

                        ssh \
                            -o StrictHostKeyChecking=no \
                            ${EC2_USER}@${EC2_HOST} \
                            "
                            curl --fail --silent --show-error --retry 10 --retry-delay 3 http://localhost:8082/ > /dev/null &&
                            echo 'Portfolio application is running.' &&
                            curl --fail --silent --show-error --retry 10 --retry-delay 3 http://localhost:8081/ > /dev/null &&
                            echo 'Java application is running.'
                            "
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '''
========================================
       DEPLOYMENT SUCCESSFUL
========================================

Portfolio:
http://18.175.208.124:80

Java Application:
http://18.175.208.124:8081

========================================
'''
        }

        failure {
            echo '''
========================================
        DEPLOYMENT FAILED
========================================

Check the Jenkins Console Output
for the stage that failed.
========================================
'''
        }

        always {
            echo 'Jenkins pipeline finished.'
        }
    }
}

