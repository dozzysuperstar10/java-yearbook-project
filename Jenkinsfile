pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        EC2_HOST = '18.134.134.80'
        EC2_USER = 'ec2-user'
        PROJECT_DIR = '/home/ec2-user/java-yearbook-project'
        SSH_CREDENTIALS = 'ec2-ssh-key'
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out code from GitHub...'

                git branch: 'main',
                    url: 'https://github.com/dozzysuperstar10/java-yearbook-project.git'
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
                    test -f myportfolio/index.html

                    echo "All required files are present."
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

echo "========================================"
echo "        CONNECTED TO EC2"
echo "========================================"

cd "\$PROJECT_DIR"

echo "Current directory:"
pwd

echo "========================================"
echo "       PULLING LATEST CODE"
echo "========================================"

git fetch origin main
git reset --hard origin/main

echo "Latest commit:"
git log -1 --oneline

echo "========================================"
echo "       CHECKING DOCKER"
echo "========================================"

docker --version
docker compose version

echo "========================================"
echo "       CHECKING BUILDX"
echo "========================================"

docker buildx version

echo "========================================"
echo "       BUILDING JAVA APPLICATION"
echo "========================================"

cd java

mvn clean package

echo "Checking generated JAR files:"
ls -lh target/

test -s target/yearbook-lambda-1.0.0.jar

echo "Java application built successfully."

cd ..

echo "========================================"
echo "       VALIDATING COMPOSE"
echo "========================================"

docker compose config -q

echo "Docker Compose configuration is valid."

echo "========================================"
echo "       BUILDING DOCKER IMAGES"
echo "========================================"

docker compose build

echo "========================================"
echo "       STARTING CONTAINERS"
echo "========================================"

docker compose up -d

echo "========================================"
echo "       CONTAINER STATUS"
echo "========================================"

docker compose ps

echo "========================================"
echo "       DEPLOYMENT FINISHED"
echo "========================================"

REMOTE
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                echo 'Verifying applications on EC2...'

                sshagent(credentials: [env.SSH_CREDENTIALS]) {
                    sh '''
                        set -e

                        ssh \
                        -o StrictHostKeyChecking=no \
                        -o ConnectTimeout=15 \
                        ${EC2_USER}@${EC2_HOST} \
                        "PROJECT_DIR='${PROJECT_DIR}' bash -s" <<'REMOTE'

set -e

cd "\$PROJECT_DIR"

echo "========================================"
echo "        CONTAINER STATUS"
echo "========================================"

docker compose ps

echo "========================================"
echo "        JAVA CONTAINER LOGS"
echo "========================================"

docker compose logs --tail=30 java-app || true

echo "========================================"
echo "        PORTFOLIO TEST"
echo "========================================"

curl \
    --fail \
    --silent \
    --show-error \
    --retry 5 \
    --retry-delay 3 \
    --retry-connrefused \
    http://localhost:80/ \
    -o /dev/null

echo "Portfolio is responding on port 80."

echo "========================================"
echo "        JAVA APPLICATION TEST"
echo "========================================"

curl \
    --fail \
    --silent \
    --show-error \
    --retry 5 \
    --retry-delay 3 \
    --retry-connrefused \
    http://localhost:8081/ \
    -o /dev/null

echo "Java application is responding on port 8081."

echo "========================================"
echo "       DEPLOYMENT VERIFIED"
echo "========================================"

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
http://18.134.134.80:80

Java Application:
http://18.134.134.80:8081
'''
        }

        failure {
            echo '''
========================================
        DEPLOYMENT FAILED
========================================

Check the Jenkins Console Output.

Find the first stage marked:
FAILED

That is normally where the problem started.
'''
        }

        always {
            echo 'Jenkins pipeline finished.'
        }
    }
}
