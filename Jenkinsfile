pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        EC2_HOST = '18.175.157.69'
        EC2_USER = 'ec2-user'
        PROJECT_DIR = '/home/ec2-user/java-yearbook-project'
        SSH_CREDENTIALS = 'ec2-ssh-key'
        GITHUB_REPO = 'https://github.com/dozzysuperstar10/java-yearbook-project.git'
    }

    stages {

        stage('Checkout') {
            steps {
                echo 'Checking out code from GitHub...'

                git(
                    branch: 'main',
                    url: "${GITHUB_REPO}"
                )
            }
        }

        stage('Check Files') {
            steps {
                sh '''
                    set -e

                    echo "== Checking required files =="

                    test -f docker-compose.yml
                    test -f java/pom.xml
                    test -f java/Dockerfile
                    test -f myportfolio/Dockerfile

                    echo "All required files are present."
                '''
            }
        }

        stage('Test EC2 SSH') {
            steps {
                sshagent(credentials: [env.SSH_CREDENTIALS]) {
                    sh '''
                        set -e

                        echo "Testing SSH connection to EC2..."

                        ssh \
                            -o StrictHostKeyChecking=no \
                            -o ConnectTimeout=15 \
                            ${EC2_USER}@${EC2_HOST} \
                            "echo 'SSH connection successful'; hostname"
                    '''
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(credentials: [env.SSH_CREDENTIALS]) {
                    sh '''
                        set -e

                        echo "== Connecting to EC2 =="

                        ssh \
                            -o StrictHostKeyChecking=no \
                            -o ConnectTimeout=15 \
                            ${EC2_USER}@${EC2_HOST} \
                            "PROJECT_DIR='${PROJECT_DIR}' bash -s" <<'REMOTE'

set -e

echo "== CONNECTED TO EC2 =="
echo "Hostname: $(hostname)"

PROJECT_DIR="${PROJECT_DIR}"

echo "== Checking project directory =="

if [ ! -d "$PROJECT_DIR/.git" ]; then
    echo "Project does not exist. Cloning repository..."

    mkdir -p "$(dirname "$PROJECT_DIR")"

    git clone \
        https://github.com/dozzysuperstar10/java-yearbook-project.git \
        "$PROJECT_DIR"
fi

cd "$PROJECT_DIR"

echo "== Updating repository =="

git fetch origin main
git reset --hard origin/main

echo "Latest commit:"
git log -1 --oneline

echo "== Checking Docker =="

docker --version
docker compose version

echo "== Checking Maven =="

if ! command -v mvn >/dev/null 2>&1; then
    echo "ERROR: Maven is not installed on EC2."
    echo "Install Maven before running the deployment."
    exit 1
fi

mvn -version

echo "== Building Java application =="

cd java

mvn clean package -DskipTests

echo "Java JAR files:"
ls -lh target/*.jar

cd ..

echo "== Validating Docker Compose =="

docker compose config -q

echo "Docker Compose configuration is valid."

echo "== Building Docker images =="

docker compose build

echo "== Starting containers =="

docker compose up -d --remove-orphans

echo "== Container status =="

docker compose ps

REMOTE
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                sshagent(credentials: [env.SSH_CREDENTIALS]) {
                    sh '''
                        set -e

                        echo "== Verifying deployment =="

                        ssh \
                            -o StrictHostKeyChecking=no \
                            -o ConnectTimeout=15 \
                            ${EC2_USER}@${EC2_HOST} \
                            "PROJECT_DIR='${PROJECT_DIR}' bash -s" <<'REMOTE'

set -e

cd "$PROJECT_DIR"

echo "== Docker containers =="

docker compose ps

echo "== Recent logs =="

docker compose logs --tail=50

echo "== Testing Portfolio on port 80 =="

curl \
    --fail \
    --silent \
    --show-error \
    --retry 5 \
    --retry-delay 3 \
    http://localhost/ \
    -o /dev/null

echo "Portfolio OK"

echo "== Testing Java application on port 8081 =="

curl \
    --fail \
    --silent \
    --show-error \
    --retry 5 \
    --retry-delay 3 \
    http://localhost:8081/ \
    -o /dev/null

echo "Java application OK"

echo "== Deployment verification completed =="

REMOTE
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "SUCCESS!"
            echo "Portfolio: http://${EC2_HOST}"
            echo "Java app:  http://${EC2_HOST}:8081"
        }

        failure {
            echo "DEPLOYMENT FAILED."
            echo "Check the first RED stage in the Jenkins console output."
        }
    }
}
