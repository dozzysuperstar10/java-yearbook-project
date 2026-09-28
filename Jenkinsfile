pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        EC2_HOST = '13.42.12.138'
        EC2_USER = 'ec2-user'
        PROJECT_DIR = '/home/ec2-user/java-yearbook-project'
        SSH_CREDENTIALS = 'ec2-ssh-key'
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out code from GitHub...'

                git branch: 'main',
                    url: 'https://github.com/ProfAkymbo/java-yearbook-project.git'
            }
        }

        stage('Check Files') {
            steps {
                echo 'Checking required project files...'

                sh '''
                    set -e

                    test -f docker-compose.yml
                    test -f java/pom.xml
                    test -f java/Dockerfile
                    test -f myportfolio/Dockerfile

                    echo "All required files are present."
                '''
            }
        }

        stage('Build Java') {
            steps {
                echo 'Building Java application with Maven...'

                sh '''
                    set -e

                    cd java

                    mvn clean package

                    test -s target/yearbook-lambda-1.0.0.jar

                    echo "Java application built successfully."
                    ls -lh target/yearbook-lambda-1.0.0.jar
                '''
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
                        "echo SSH connection successful && hostname && whoami"
                    '''
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                echo 'Deploying application to EC2...'

                sshagent(credentials: [env.SSH_CREDENTIALS]) {
                    sh '''
                        set -e

                        ssh \
                        -o StrictHostKeyChecking=no \
                        -o ConnectTimeout=15 \
                        ${EC2_USER}@${EC2_HOST} \
                        "PROJECT_DIR='${PROJECT_DIR}' bash -s" <<'REMOTE'

                        set -e

                        echo "================================"
                        echo "Connected to EC2"
                        echo "================================"

                        cd "\$PROJECT_DIR"

                        echo "Pulling latest code from GitHub..."

                        git pull --ff-only origin main

                        echo "Checking Docker..."

                        docker --version
                        docker compose version

                        echo "Building Java application..."

                        cd java

                        mvn clean package

                        test -s target/yearbook-lambda-1.0.0.jar

                        cd ..

                        echo "Validating Docker Compose..."

                        docker compose config -q

                        echo "Building Docker images..."

                        docker compose build --no-cache

                        echo "Starting containers..."

                        docker compose up -d

                        echo "Checking container status..."

                        docker compose ps

                        echo "================================"
                        echo "Deployment completed"
                        echo "================================"

REMOTE
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Checking applications on EC2...'

                sshagent(credentials: [env.SSH_CREDENTIALS]) {
                    sh '''
                        set -e

                        ssh \
                        -o StrictHostKeyChecking=no \
                        ${EC2_USER}@${EC2_HOST} \
                        "PROJECT_DIR='${PROJECT_DIR}' bash -s" <<'REMOTE'

                        set -e

                        cd "\$PROJECT_DIR"

                        echo "===== CONTAINERS ====="

                        docker compose ps

                        echo "===== JAVA LOGS ====="

                        docker compose logs --tail=30 java-app || true

                        echo "===== PORTFOLIO TEST ====="

                        curl --fail \
                        --silent \
                        --show-error \
                        --retry 5 \
                        --retry-delay 3 \
                        --retry-connrefused \
                        http://localhost:8082/ \
                        -o /dev/null

                        echo "Portfolio is responding."

                        echo "===== JAVA TEST ====="

                        curl --fail \
                        --silent \
                        --show-error \
                        --retry 5 \
                        --retry-delay 3 \
                        --retry-connrefused \
                        http://localhost:8081/ \
                        -o /dev/null

                        echo "Java application is responding."

                        echo "===== DEPLOYMENT VERIFIED ====="

REMOTE
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
http://51.24.249.113:8082

Java Application:
http://51.24.249.113:8081
'''
        }

        failure {
            echo '''
========================================
        DEPLOYMENT FAILED
========================================

Check the Jenkins Console Output.
Look for the first stage that failed.
'''
        }

        always {
            echo 'Jenkins pipeline finished.'
        }
    }
}
