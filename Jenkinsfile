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
                echo '========================================'
                echo 'Checking out code from GitHub'
                echo '========================================'

                checkout scm
            }
        }

        stage('Check Files') {
            steps {
                echo 'Checking required project files...'

                sh '''
                    set -e

                    echo "Project directory:"
                    pwd

                    echo ""
                    echo "Project files:"
                    ls -la

                    echo ""
                    echo "Checking required files..."

                    test -f docker-compose.yml
                    test -f java/pom.xml
                    test -f java/Dockerfile
                    test -f myportfolio/Dockerfile
                    test -f myportfolio/index.html

                    echo ""
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

                        echo ""
                        echo "Checking generated JAR..."

                        test -s target/yearbook-lambda-1.0.0.jar

                        echo ""
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
                        credentialsId: "${SSH_CREDENTIALS}",
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USERNAME'
                    )
                ]) {

                    sh '''
                        set -e

                        echo "Testing SSH connection..."
                        echo "EC2 Host: ${EC2_HOST}"
                        echo "EC2 User: ${SSH_USERNAME}"

                        chmod 600 "$SSH_KEY"

                        ssh \
                            -o StrictHostKeyChecking=no \
                            -o ConnectTimeout=15 \
                            -o BatchMode=yes \
                            -i "$SSH_KEY" \
                            "${SSH_USERNAME}@${EC2_HOST}" \
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
                        credentialsId: "${SSH_CREDENTIALS}",
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
                            -i "$SSH_KEY" \
                            "${SSH_USERNAME}@${EC2_HOST}" \
                            "mkdir -p ${PROJECT_DIR}"

                        echo "Uploading project files..."

                        tar \
                            --exclude='.git' \
                            --exclude='java/target' \
                            -czf project.tar.gz .

                        scp \
                            -o StrictHostKeyChecking=no \
                            -o ConnectTimeout=15 \
                            -i "$SSH_KEY" \
                            project.tar.gz \
                            "${SSH_USERNAME}@${EC2_HOST}:${PROJECT_DIR}/project.tar.gz"

                        echo "Extracting project on EC2..."

                        ssh \
                            -o StrictHostKeyChecking=no \
                            -i "$SSH_KEY" \
                            "${SSH_USERNAME}@${EC2_HOST}" \
                            "
                                cd ${PROJECT_DIR}

                                tar -xzf project.tar.gz

                                rm -f project.tar.gz

                                echo 'Project files deployed.'

                                echo 'Stopping existing containers...'
                                docker compose down || true

                                echo 'Building and starting containers...'
                                docker compose up -d --build

                                echo 'Containers started.'

                                docker compose ps
                            "

                        rm -f project.tar.gz

                        echo "Deployment completed successfully."
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
                        credentialsId: "${SSH_CREDENTIALS}",
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USERNAME'
                    )
                ]) {

                    sh '''
                        set -e

                        chmod 600 "$SSH_KEY"

                        ssh \
                            -o StrictHostKeyChecking=no \
                            -i "$SSH_KEY" \
                            "${SSH_USERNAME}@${EC2_HOST}" \
                            "
                                echo '========================================'
                                echo 'Docker Containers'
                                echo '========================================'

                                docker compose -f ${PROJECT_DIR}/docker-compose.yml ps

                                echo ''
                                echo '========================================'
                                echo 'Java Application Test'
                                echo '========================================'

                                curl -f http://localhost:8081/ || true

                                echo ''
                                echo '========================================'
                                echo 'Portfolio Test'
                                echo '========================================'

                                curl -I -f http://localhost/ || true
                            "

                        echo ""
                        echo "Deployment verification completed."
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
Java application and portfolio deployed.
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
