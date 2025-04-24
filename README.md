# devops-project

This project provides a complete DevOps pipeline for a cloud-native microservices-based e-commerce application, using **Terraform, Ansible, Jenkins, Docker, Kubernetes (EKS), SonarQube, Vault, and AWS**.

---

## Repository Structure

├── terraform/ # Infrastructure as Code ├── ansible/ # Configuration management playbooks ├── jenkins/ # Jenkins pipeline setup ├── helm-charts/ # Kubernetes deployment files ├── vault/ # Vault configuration ├── docs/ # Documentation (LLD, IAM, security) └── README.md # This file

---

## Prerequisites

Ensure the following tools are installed:

- Terraform
- Ansible
- AWS CLI & configured IAM credentials
- Kubectl
- Helm
- Docker
- Jenkins (can be installed using Ansible)
- Vault CLI

---

## 1️⃣ Infrastructure Setup (Terraform)

Provision AWS resources:

```bash
cd terraform
terraform init
terraform apply -var-file="dev.tfvars"
```

Provisioned resources:

VPC, Public & Private Subnets, NAT Gateway, Internet Gateway

EC2 instances (Jenkins, Vault, SonarQube)

EKS Cluster

RDS PostgreSQL

S3 bucket & DynamoDB for remote state

📝 Remote state backend is configured in backend.tf.

2️⃣ Configuration Management (Ansible)
Install and configure tools on provisioned EC2 instances:

```bash

cd ansible
ansible-playbook -i inventory setup.yml
```

Playbooks:

jenkins.yml – Installs Jenkins & plugins

vault.yml – Installs HashiCorp Vault and enables KV secrets

sonarqube.yml – Installs and configures SonarQube

Configures Jenkins integration with Vault and SonarQube

---

3️⃣ CI/CD Pipeline (Jenkins + GitHub)
The pipeline is defined in jenkins/Jenkinsfile.

Triggered on push to GitHub repo.

Pipeline steps:

Run unit tests

SonarQube code quality scan

Build Docker images

Push to Amazon ECR

Retrieve secrets from Vault

Deploy to EKS using Helm

Set GitHub webhook to trigger Jenkins.

4️⃣ Kubernetes Deployment (Helm + EKS)
Ensure your kubeconfig is set:

```bash
aws eks update-kubeconfig --name ecommerce-eks-cluster
```

Deploy all services using Helm:

```bash
cd helm-charts
helm install checkout-service ./checkout
helm install auth-service ./auth
```

Includes:

Namespaces per service

Basic RBAC

Network policies

HPA (Horizontal Pod Autoscaler)

5️⃣ Security Practices
IAM: Roles with least privilege for EC2, EKS, Jenkins

Secrets Management: Vault stores and manages secrets

SonarQube: Code scanned for static analysis

No secrets in code: All credentials managed via Vault

🧪 Verification Checklist
✅ Microservices deployed to EKS
✅ CI/CD pipeline auto-triggers on GitHub push
✅ Docker images built & pushed to ECR
✅ Secrets retrieved securely via Vault
✅ SonarQube scan passes quality gates
✅ Infrastructure reproducible via Terraform

📄 Documentation.,
docs/LLD.md: Low-Level Design

docs/iam-roles.md: IAM role descriptions

docs/security.md: Vault setup, RBAC, etc.

🤝 Contributors
DevOps Engineer: Youssef Ismail
