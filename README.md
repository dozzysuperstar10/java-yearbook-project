 Modern End-to-End DevOps Deployment

![Docker](https://img.shields.io/badge/Docker-Containerization-2496ED?logo=docker&logoColor=white)
![Java](https://img.shields.io/badge/Java-17-ED8B00?logo=openjdk&logoColor=white)
![Maven](https://img.shields.io/badge/Maven-Build-C71A36?logo=apachemaven&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-Infrastructure-844FBA?logo=terraform&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-Automation-EE0000?logo=ansible&logoColor=white)
![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-D24939?logo=jenkins&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazonaws&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-Source_Control-181717?logo=github&logoColor=white)

## Project Overview

This project demonstrates a modern, end-to-end DevOps pipeline for provisioning AWS infrastructure and deploying two applications to an Amazon EC2 server.

The solution combines Infrastructure as Code (IaC), configuration management, containerization, version control, and Continuous Integration and Continuous Deployment (CI/CD).

The pipeline is designed to automate the journey from source code in GitHub to running applications on AWS.

## Applications

### 1. Java Yearbook Application

A Java application built with Maven and packaged as an executable JAR. The application runs inside a Docker container and listens on port `8081`.

### 2. Portfolio Web Application

A static portfolio website built with HTML and CSS and served using Nginx in a Docker container. The website is exposed on port `80`.

<<<<<<< HEAD
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
=======
## DevOps Architecture
>>>>>>> 4f17d4f (Improve end-to-end DevOps project README)


Developer
   |
   | Git Push
   v
GitHub Repository
   |
   v
Jenkins CI/CD Pipeline
(WSL / Ubuntu)
   |
   | Build Java Application
   | Validate Project Files
   | Connect through SSH
   v
AWS EC2 Server
   |
   +---- Terraform provisions infrastructure
   |
   +---- Ansible configures the server
   |
   +---- Docker Engine
             |
             v
        Docker Compose
          /         \
         v           v
   Portfolio App   Java App
      Nginx         Java
      Port 80      Port 8081
```

## Technologies Used

| Technology | Responsibility |
|---|---|
| Git | Version control |
| GitHub | Source code hosting |
| Jenkins | CI/CD pipeline automation |
| Terraform | AWS infrastructure provisioning |
| Ansible | Server configuration and automation |
| Docker | Application containerization |
| Docker Compose | Running and managing multiple containers |
| AWS EC2 | Application hosting |
| AWS VPC | Network infrastructure |
| AWS Security Groups | Network access control |
| Maven | Java build and dependency management |
| Java 17 | Java application runtime |
| Nginx | Portfolio web server |
| Linux / WSL / Ubuntu | Development and Jenkins environment |

## Repository Structure


java-yearbook-project/
├── ansible/
│   ├── inventory
│   ├── setup.yml
│   └── deploy.yml
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
│
├── java/
│   ├── src/
│   │   └── main/
│   ├── pom.xml
│   └── Dockerfile
│
├── myportfolio/
│   ├── index.html
│   └── Dockerfile
│
├── docker-compose.yml
├── Jenkinsfile
├── README.md
└── .gitignore
```

*Note: This structure represents the intended project layout. Keep only the filenames and directories that actually exist in the repository.*

## Infrastructure Provisioning with Terraform

Terraform is used to define and provision the AWS infrastructure required to host the applications.

The infrastructure configuration includes:

- AWS VPC
- Public subnet
- Internet Gateway
- Public route table and route table association
- Security Group
- EC2 instance

Terraform enables infrastructure to be managed through version-controlled configuration files.

Before provisioning infrastructure, the configuration should be validated and the execution plan reviewed.

```bash
cd terraform
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Run `terraform apply` only after reviewing the proposed changes and confirming they are safe.

## Server Configuration with Ansible

Ansible automates the configuration of the EC2 deployment server.

Depending on the configured playbooks, server setup and deployment tasks include:

- Installing and configuring Docker
- Preparing Docker Compose
- Installing Git
- Creating the application deployment directory
- Preparing the server to run the application containers

Ansible helps make server configuration repeatable and reduces manual setup.

## Application Containerization

Docker packages each application and its runtime requirements into a container.

### Java Application

The Java application is built using Maven and packaged as a JAR before being copied into its Docker image.

Typical build command:

```bash
cd java
mvn clean package
```

The Java container exposes port `8081`.

### Portfolio Application

The portfolio application contains the website's HTML and CSS files and is served through Nginx.

The portfolio container exposes port `80`.

## Docker Compose Deployment

<<<<<<< HEAD
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
=======
Docker Compose manages both application containers on the EC2 server.
>>>>>>> 4f17d4f (Improve end-to-end DevOps project README)

The deployment includes:

| Service | Purpose | Host Port |
|---|---|---:|
| `java-app` | Java Yearbook Application | 8081 |
| `portfolio` | Portfolio Website | 80 |

From the project directory, the applications can be built and started using:

```bash
docker compose up -d --build
```

Check the running containers:

```bash
docker compose ps
```

View application logs:

```bash
docker compose logs
```

These commands should be run from the directory containing `docker-compose.yml`.

## Jenkins CI/CD Pipeline

Jenkins provides continuous integration and deployment automation.

In this project, Jenkins runs in a WSL/Ubuntu environment and retrieves the pipeline definition from the GitHub repository.

The pipeline is defined in `Jenkinsfile`.

The intended workflow is:

1. Check out the source code from GitHub.
2. Validate required project files.
3. Build the Java application with Maven.
4. Verify that the application JAR was generated.
5. Connect to the EC2 deployment server using SSH.
6. Deploy the latest application code and rebuild the containers.
7. Verify that the containers are running.

The deployment server is configured separately from the Jenkins controller.

Jenkins is accessed locally at:

`http://localhost:8080`

This address is for the Jenkins interface on the machine running Jenkins; it is not the public URL of either application.

## Application Access

After successful deployment, use the public IP address of the running EC2 instance.

| Application | URL |
|---|---|
| Portfolio Website | `http://EC2-PUBLIC-IP/` |
| Java Yearbook Application | `http://EC2-PUBLIC-IP:8081/` |
| Jenkins Dashboard | `http://localhost:8080/` from the Jenkins host |

Replace `EC2-PUBLIC-IP` with the current public IPv4 address of the deployment instance.

These URLs work only when the applications are running and the relevant ports are allowed by the EC2 Security Group and host firewall.

## AWS Security

The EC2 Security Group must permit the traffic required for administration and application access.

| Port | Purpose |
|---:|---|
| 22 | SSH administration |
| 80 | Portfolio website |
| 8081 | Java application |
| 8080 | Jenkins, only if intentionally exposed on the relevant host |

For improved security:

- Restrict SSH access to trusted IP addresses.
- Avoid exposing Jenkins directly to the public internet.
- Store SSH private keys and credentials in Jenkins Credentials.
- Never commit AWS access keys, private keys, passwords, or other secrets to GitHub.
- Exclude Terraform state and local secret files from version control where appropriate.

## GitHub Integration

GitHub serves as the central source code repository.

Developers commit and push changes to the repository. Jenkins can then retrieve the updated source code and execute the configured pipeline.

Typical Git workflow:

```bash
git add .
git commit -m "Update application and DevOps configuration"
git push origin main
```

Automatic deployment after a push requires the Jenkins job to be configured with the appropriate trigger, such as a GitHub webhook or polling.

## Project Objectives

The project is designed to demonstrate:

- [x] Git and GitHub source control
- [x] Terraform-based AWS infrastructure configuration
- [x] AWS networking and Security Group configuration
- [x] Ansible-based server configuration
- [x] Docker containerization
- [x] Docker Compose multi-container deployment
- [x] Maven-based Java application builds
- [x] Jenkins pipeline configuration
- [x] SSH-based deployment automation
- [x] Deployment of a Java application and a portfolio website

*The checklist describes the project's intended capabilities; mark each item complete only after verifying it in your environment.*

## Conclusion

This project brings together GitHub, Jenkins, Terraform, Ansible, Docker, Docker Compose, Maven, and AWS EC2 to demonstrate an end-to-end DevOps deployment workflow.

It illustrates how infrastructure provisioning, application builds, configuration management, and deployment automation can work together to deliver applications from source control to a cloud-hosted environment.

The project provides a practical foundation for learning CI/CD, Infrastructure as Code, containerization, and cloud deployment.

---

**Project:** Modern End-to-End DevOps Deployment

**Repository:** [java-yearbook-project](https://github.com/dozzysuperstar10/java-yearbook-project)

**Learning Context:** Bloomy Technologies — Linux, DevOps & Cloud, Batch 9
