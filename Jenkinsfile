pipeline {

    agent any

    environment {
 -   AWS_DEFAULT_REGION = 'eu-west-2'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Java Build') {
            steps {
                sh '''
                    cd java
                    mvn clean package
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                sh '''
                    cd terraform
                    terraform init
                '''
            }
        }

        stage('Terraform Validate') {
            steps {
                sh '''
                    cd terraform
                    terraform validate
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                sh '''
                    cd terraform
                    terraform apply -auto-approve
                '''
            }
        }

        stage('Get EC2 IP') {
            steps {
                script {
                    env.EC2_IP = sh(
                        script: '''
                            cd terraform
                            terraform output -raw ec2_public_ip
                        ''',
                        returnStdout: true
                    ).trim()

                    echo "EC2 IP: ${env.EC2_IP}"
                }
            }
        }

        stage('Create Ansible Inventory') {
            steps {
                sh '''
                    cat > ansible/inventory.ini <<EOF
[webserver]
${EC2_IP} ansible_user=ec2-user ansible_ssh_private_key_file=${WORKSPACE}/devops-key.pem
EOF
                '''
            }
        }

        stage('Ansible Deployment') {
            steps {
                sh '''
                    ansible-playbook \
                    -i ansible/inventory.ini \
                    ansible/playbook.yml
                '''
            }
        }
    }

    post {

        success {
            echo "Deployment successful"
            echo "Portfolio: http://${EC2_IP}"
            echo "Java App: http://${EC2_IP}:8081"
        }

        failure {
            echo "Deployment failed"
        }
    }
}
