# Low-Level Design (LLD) - devops-project

This document provides a detailed low-level design for the automated DevOps pipeline and infrastructure setup of a microservices-based e-commerce platform using AWS, Jenkins, Terraform, Ansible, Docker, Kubernetes (EKS), SonarQube, Vault, and other tools.

---

## 1. **System Overview**

The goal of this project is to implement a cloud-native microservices-based e-commerce platform. The system involves various components:

- **Microservices**: Auth, Checkout, Product, Cart, etc.
- **CI/CD Pipeline**: Automated pipeline for building, testing, and deploying microservices.
- **Infrastructure as Code**: All AWS resources are provisioned using Terraform.
- **Secrets Management**: Vault is used to securely manage application secrets.

---

## 2. **Architecture Diagram**

**Diagram:**

         +----------------+      +------------------+
         |  GitHub Repo   | ---> |    Jenkins       | ----> Docker Images
         +----------------+      +------------------+           |
                 |                          |                |
                 |                     +----v----+           |
                 |                     | Vault   |<----------+
                 |                     +---------+
         +----------------+               |
         | SonarQube       | <------------+
         +----------------+               |
                 |                        |
        +--------v---------+      +-------v-------+
        | EKS Cluster      | ---> | Microservices |
        | (Kubernetes)     |      | (Pods)        |
        +------------------+      +---------------+
                 |
      +----------v----------+
      | RDS PostgreSQL DB    |
      +----------------------+


---

## 3. **Infrastructure Design**

### 3.1 **AWS Resources**

- **VPC (Virtual Private Cloud)**: Configured with public and private subnets, NAT Gateway, and Internet Gateway.
- **EC2 Instances**: 
    - Jenkins: Used for CI/CD automation.
    - Vault: Stores sensitive information.
    - SonarQube: Used for code quality checks.
- **EKS (Elastic Kubernetes Service)**: Kubernetes cluster for deploying the microservices.
- **RDS**: PostgreSQL instance to store application data.
- **S3**: For storing Terraform state securely.
- **DynamoDB**: Used for locking and state management in Terraform.

### 3.2 **AWS IAM Roles**

- **EC2 Instances**: Limited IAM roles for Jenkins, Vault, and SonarQube.
- **EKS**: Access policies for Kubernetes clusters.
- **S3 & DynamoDB**: Access to store Terraform state.
- **Vault**: Restricted access to manage and retrieve secrets.

### 3.3 **Kubernetes Design**

- **Namespaces**: Each microservice is deployed in its own namespace for isolation and management.
- **Horizontal Pod Autoscaler (HPA)**: Automatically scales services based on demand.
- **RBAC (Role-Based Access Control)**: Ensures that only authorized users and services can interact with resources.
- **Network Policies**: Controls communication between services to enhance security.
  
---

## 4. **Microservices Design**

### 4.1 **Docker Containers**

Each microservice is containerized using **Docker**. Each microservice has a Dockerfile that specifies how to build the image, install dependencies, and run the service.

- **Auth Service**: Manages user authentication.
- **Checkout Service**: Handles order processing and checkout.
- **Product Service**: Manages product catalog.
- **Cart Service**: Manages customer shopping cart.

Docker images are built in the Jenkins pipeline and pushed to **Amazon ECR**.

### 4.2 **Helm Charts**

Helm charts are used to deploy the microservices into the Kubernetes cluster. Each service has a separate Helm chart to facilitate easy management and upgrades.

---

## 5. **CI/CD Pipeline**

The CI/CD pipeline is implemented in **Jenkins**, and the pipeline file is located in `jenkins/Jenkinsfile`. The following steps are included:

1. **GitHub Webhook**: The pipeline is triggered on every push to the GitHub repository.
2. **Unit Tests**: The pipeline runs unit tests for the microservices.
3. **SonarQube Scan**: Code quality is enforced by SonarQube.
4. **Docker Build**: Docker images are built for each microservice.
5. **Push to ECR**: The built Docker images are pushed to Amazon ECR.
6. **Helm Deployment**: The images are deployed to EKS using Helm charts.

---

## 6. **Secrets Management**

**Vault** is used to manage and securely store application secrets such as:

- Database credentials
- API keys
- Docker registry credentials

Vault is integrated into the Jenkins pipeline to retrieve secrets securely during the build and deployment process.

---

## 7. **Security Measures**

### 7.1 **IAM Roles**

IAM roles are set with the **least privilege** for all AWS resources to ensure that only authorized services and users can access necessary resources.

### 7.2 **SonarQube Integration**

SonarQube is used for static code analysis, ensuring that code quality checks are performed during the CI/CD process. The integration with Jenkins allows automatic quality gate checks before deploying the microservices.

### 7.3 **Vault Security**

- Vault is used to store all sensitive credentials and secrets.
- Access policies are defined to restrict which users and services can access specific secrets.

### 7.4 **RBAC and Network Policies**

- **RBAC**: Ensures only authorized users and services can access Kubernetes resources.
- **Network Policies**: Control inter-service communication within the Kubernetes cluster.

---

## 8. **Logging and Monitoring**

- **CloudWatch**: Used for logging and monitoring all AWS resources.
- **Prometheus**: Monitors the EKS cluster and microservices.
- **Grafana**: Visualizes metrics from Prometheus and provides dashboards for system monitoring.

---

## 9. **Deployment Process**

The deployment process is automated as part of the CI/CD pipeline. Once the Docker images are built and pushed to ECR, Helm charts are used to deploy the services to EKS.

---

## 10. **Summary of Key Components**

| Component              | Technology    | Description                                |
|------------------------|---------------|--------------------------------------------|
| Infrastructure          | Terraform     | Provision AWS resources (VPC, EC2, RDS, EKS, etc.) |
| CI/CD                  | Jenkins       | Automates the build, test, and deployment pipeline |
| Containerization        | Docker        | Containerizes microservices                |
| Orchestration           | Kubernetes    | EKS for deploying and managing services   |
| Secrets Management      | Vault         | Manages secrets and credentials securely  |
| Code Quality & Security | SonarQube     | Scans code for quality and vulnerabilities |
| Database                | PostgreSQL    | RDS for storing application data          |
| Monitoring              | Prometheus    | Collects metrics from microservices       |
| Monitoring Visualization| Grafana       | Dashboards for monitoring the infrastructure and microservices |

---

## 11. **Conclusion**

This Low-Level Design outlines how the microservices-based e-commerce platform is structured, from infrastructure setup on AWS to the deployment of microservices on EKS. The project follows best practices in security, scalability, and automation, leveraging the power of AWS, Terraform, Jenkins, Kubernetes, and Vault.

