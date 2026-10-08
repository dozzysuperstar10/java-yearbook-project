# DevOps Modern End-to-End Deployment

![Docker](https://img.shields.io/badge/Docker-Containerized-blue)
![Java](https://img.shields.io/badge/Java-21-orange)
![Maven](https://img.shields.io/badge/Maven-Build-red)
![Terraform](https://img.shields.io/badge/Terraform-IaC-purple)
![Ansible](https://img.shields.io/badge/Ansible-Automation-black)
![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-red)

## Overview

This project demonstrates an end-to-end DevOps workflow for deploying and managing multiple applications.

The project combines containerization, source control, infrastructure as code, configuration management and CI/CD automation.

# Final DevOps Project

## End-to-End AWS DevOps Deployment

This project demonstrates an end-to-end DevOps workflow for deploying two applications to AWS using Infrastructure as Code, configuration management, containerization, and CI/CD.

### Applications

1. Portfolio Web Application
2. Java Application

### DevOps Workflow

GitHub → Jenkins → AWS EC2 → Docker Compose → Applications

---

##  Project Architecture

```text
                         GitHub
                            |
                            | git push
                            v
                        Jenkins
                       (WSL/Ubuntu)
                            |
                            | SSH
                            v
                    AWS EC2 Server
                  Created by Terraform
                            |
                         Ansible
                            |
                            v
                     Docker Compose
                       /          \
                      /            \
                     v              v
              Portfolio App      Java App
                 :80             :8081


Technologies Used
- 
| Technology     | Purpose                             |
| -------------- | ----------------------------------- |
| Git            | Version control                     |
| GitHub         | Source code repository              |
| Jenkins        | CI/CD automation                    |
| Terraform      | AWS Infrastructure as Code          |
| Ansible        | Server configuration and deployment |
| Docker         | Application containerization        |
| Docker Compose | Multi-container deployment          |
| AWS EC2        | Application server                  |
| AWS VPC        | Network infrastructure              |
| Maven          | Java application build              |
| Linux/WSL      | Development and Jenkins environment |


Project Applications

Portfolio Application

The portfolio application is a web application served using Nginx.

Port:

8081

Access:

http://EC2-PUBLIC-IP:8081

Java Application

The Java application is packaged using Maven and deployed inside a Docker container.

Port:

8081

Access:

http://EC2-PUBLIC-IP:8081

Project Structure

final-devops-project/
│
├── ansible/
│   ├── inventory
│   ├── setup.yml
│   └── deploy.yml
│
├── terraform/
│   ├── main.tf
│   └── other Terraform files
│
├── java-app/
│   ├── src/
│   ├── pom.xml
│   └── Dockerfile
│
├── portfolio/
│   ├── index.html
│   ├── style.css
│   └── Dockerfile
│
├── docker-compose.yml
├── Jenkinsfile
├── README.md
└── .gitignore

Terraform state files, SSH private keys, environment files, and other sensitive files are excluded using .gitignore.
Terraform Infrastructure

Terraform is used to create the AWS infrastructure required by the application.

AWS resources

Terraform creates:

VPC
Public subnet
Internet Gateway
Route table
Route table association
Security Group
EC2 instance
Ansible Configuration

Ansible is used to configure the Terraform-created EC2 server.

The Ansible configuration installs and configures:

Docker
Docker Compose
Git
Required server configuration
Docker Deployment

Docker is used to containerize the applications.

Docker Compose manages both application containers
Jenkins CI/CD

Jenkins is running on the WSL/Ubuntu environment.

Jenkins is accessed through:

http://localhost:8080

Jenkins connects to the AWS EC2 deployment server using SSH.

The EC2 SSH private key is stored securely on the Jenkins server and is not committed to GitHub.

9. Jenkins Pipeline

The Jenkins pipeline automates the deployment process.

The pipeline is defined in:

Jenkinsfile

The deployment workflow is:

GitHub
   |
   v
Jenkins
   |
   v
SSH to EC2
   |
   v
git pull origin main
   |
   v
docker-compose down
   |
   v
docker-compose up -d --build
   |
   v
Verify Containers

Jenkins acts as the CI/CD controller while the AWS EC2 server performs the actual application deployment
AWS Security Group

The EC2 Security Group allows the required ports for administration and application access.

Port	Purpose
22	SSH
80	HTTP
8080	Jenkins
8081	Java Application
8082	Portfolio Application

For a production environment, SSH and application ports should be restricted to trusted sources instead of allowing unrestricted internet access

Final DevOps Workflow
                         DEVELOPER
                             |
                             | git push
                             v
                          GITHUB
                             |
                             v
                         JENKINS
                       WSL/Ubuntu
                             |
                             | SSH
                             v
                    AWS EC2 SERVER
                   Created by Terraform
                             |
                          Ansible
                             |
                             v
                       Docker Engine
                             |
                             v
                     Docker Compose
                        /         \
                       /           \
                      v             v
                Portfolio App    Java App
                   :80           :8081

Tool Responsibilities

Tool	Responsibility
GitHub	        Source code management
Jenkins 	CI/CD automation
Terraform	Infrastructure provisioning
Ansible 	EC2 configuration
Docker	        Containerization
Docker Compose	Application deployment
AWS EC2 	Application hosting
Maven	        Java application build

Project Goals Achieved
 Git and GitHub source control
 AWS infrastructure with Terraform
 AWS VPC
 Public subnet
 Internet Gateway
 Route table
 Security Group
 EC2 deployment
 Ansible server configuration
 Docker installation
 Docker Compose installation
 Portfolio application containerization
 Java application containerization
 Docker Compose deployment
 Jenkins installation
 Jenkins SSH connection to EC2
 Jenkins CI/CD pipeline
 Automated deployment to EC2
 GitHub → Jenkins → EC2 workflow
 Running Portfolio application
 Running Java application

Conclusion

This project demonstrates a complete end-to-end DevOps deployment workflow using:

GitHub + Jenkins + Terraform + Ansible + Docker + Docker Compose + AWS EC2

The final deployment process allows application changes to move from source control to a running AWS environment through an automated CI/CD workflow

