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
                echo '========================================'
                echo 'Checking out code from GitHub'
                echo '========================================'

                checkout scm
            }
        }

        stage('Check Files') {
            steps {
                echo '========================================'
                echo 'Checking required project files'
                echo '========================================'

                sh '''
                    set -e

                    echo "Project directory:"
                    pwd

                    echo
                    echo "Project files:"
                    ls -la

                    echo
                    echo "Checking required files..."

                    test -f docker-compose.yml
                    test -f java/pom.xml
                    test -f java/Dockerfile
                    test -f myportfolio/Dockerfile
                    test -f myportfolio/index.html

                    echo
                    echo "All required files found."
                '''
            }
        }

        stage('Build Java') {
            steps {
                echo '========================================'
                echo 'Building Java application'
                echo '========================================'

                dir('java') {
                    sh '''
                        set -e

                        echo "Running Maven build..."

                        mvn clean package

                        echo
                        echo "Checking generated JAR..."

                        test -s target/yearbook-lambda-1.0.0.jar

                        echo
                        echo "Java build successful."

                        ls -lh target/yearbook-lambda-1.0.0.jar
                    '''
                }
            }
        }

        stage('Test EC2 SSH') {
            steps {
                echo '========================================'
                echo 'Testing SSH connection to EC2'
                echo '========================================'

                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: SSH_CREDENTIALS,
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USERNAME'
                    )
                ]) {
                    sh '''
                        set -e

                        chmod 600 "$SSH_KEY"

                        echo "Connecting to EC2..."

                        ssh \
                            -o StrictHostKeyChecking=no \
                            -o ConnectTimeout=15 \
                            -o BatchMode=yes \
                            -i "$SSH_KEY" \
                            "$SSH_USERNAME@$EC2_HOST" \
                            "echo 'SSH connection successful'; hostname; whoami"
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                echo '========================================'
                echo 'Deploying application to EC2'
                echo '========================================'

                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: SSH_CREDENTIALS,
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USERNAME'
                    )
                ]) {
                    sh '''
                        set -e

                        chmod 600 "$SSH_KEY"

                        echo "Creating project directory on EC2..."

                        ssh \
                            -o StrictHostKeyChecking=no \
                            -o ConnectTimeout=15 \
                            -i "$SSH_KEY" \
                            "$SSH_USERNAME@$EC2_HOST" \
                            "mkdir -p '$PROJECT_DIR'"

                        echo
                        echo "Creating deployment archive..."

                        # IMPORTANT:
                        # Archive is created outside the Jenkins workspace
                        # so tar does not try to archive the archive itself.

                        ARCHIVE="/tmp/java-yearbook-project-${BUILD_NUMBER}.tar.gz"

                        rm -f "$ARCHIVE"

                        tar \
                            --exclude=.git \
                            --exclude=java/target \
                            -czf "$ARCHIVE" \
                            -C "$WORKSPACE" .

                        echo
                        echo "Archive created:"
                        ls -lh "$ARCHIVE"

                        echo
                        echo "Uploading project to EC2..."

                        scp \
                            -o StrictHostKeyChecking=no \
                            -o ConnectTimeout=15 \
                            -i "$SSH_KEY" \
                            "$ARCHIVE" \
                            "$SSH_USERNAME@$EC2_HOST:/tmp/"

                        echo
                        echo "Extracting project on EC2..."

                        ssh \
                            -o StrictHostKeyChecking=no \
                            -o ConnectTimeout=15 \
                            -i "$SSH_KEY" \
                            "$SSH_USERNAME@$EC2_HOST" "
                                set -e

                                mkdir -p '$PROJECT_DIR'

                                tar \
                                    -xzf \
                                    '/tmp/java-yearbook-project-${BUILD_NUMBER}.tar.gz' \
                                    -C '$PROJECT_DIR'

                                rm -f \
                                    '/tmp/java-yearbook-project-${BUILD_NUMBER}.tar.gz'

                                cd '$PROJECT_DIR'

                                echo 'Project uploaded successfully.'

                                echo
                                echo 'Project contents:'
                                ls -la
                            "

                        rm -f "$ARCHIVE"

                        echo
                        echo "Project files successfully deployed to EC2."
                    '''
                }
            }
        }

        stage('Docker Deploy') {
            steps {
                echo '========================================'
                echo 'Building and starting Docker containers'
                echo '========================================'

                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: SSH_CREDENTIALS,
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USERNAME'
                    )
                ]) {
                    sh '''
                        set -e

                        chmod 600 "$SSH_KEY"

                        ssh \
                            -o StrictHostKeyChecking=no \
                            -o ConnectTimeout=15 \
                            -i "$SSH_KEY" \
                            "$SSH_USERNAME@$EC2_HOST" "
                                set -e

                                cd '$PROJECT_DIR'

                                echo 'Current directory:'
                                pwd

                                echo
                                echo 'Stopping existing containers...'

                                docker compose down || true

                                echo
                                echo 'Building Docker images...'

                                docker compose build --no-cache

                                echo
                                echo 'Starting containers...'

                                docker compose up -d

                                echo
                                echo 'Docker containers:'

                                docker compose ps
                            "
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                echo '========================================'
                echo 'Verifying deployment'
                echo '========================================'

                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: SSH_CREDENTIALS,
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USERNAME'
                    )
                ]) {
                    sh '''
                        set -e

                        chmod 600 "$SSH_KEY"

                        ssh \
                            -o StrictHostKeyChecking=no \
                            -o ConnectTimeout=15 \
                            -i "$SSH_KEY" \
                            "$SSH_USERNAME@$EC2_HOST" "
                                set -e

                                cd '$PROJECT_DIR'

                                echo '========================================'
                                echo 'Project Directory'
                                echo '========================================'

                                pwd

                                echo
                                echo '========================================'
                                echo 'Docker Compose Status'
                                echo '========================================'

                                docker compose ps

                                echo
                                echo '========================================'
                                echo 'Docker Containers'
                                echo '========================================'

                                docker ps

                                echo
                                echo '========================================'
                                echo 'Deployment Verification Complete'
                                echo '========================================'
                            "
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '========================================'
            echo '        DEPLOYMENT SUCCESSFUL'
            echo '========================================'
            echo 'Java application and portfolio deployed.'
            echo '========================================'
        }

        failure {
            echo '========================================'
            echo '        DEPLOYMENT FAILED'
            echo '========================================'
            echo 'Check the Jenkins Console Output'
            echo 'for the stage that failed.'
            echo '========================================'
        }

        always {
            echo 'Jenkins pipeline finished.'
        }
    }
}
