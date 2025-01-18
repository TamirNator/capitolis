# Deployment Guide for Jenkins, Grafana, and Movie App on AWS

This guide provides detailed steps to deploy a CI/CD system, monitoring, and application stack using Terraform, Helm, and Docker.

---

## Prerequisites

Before starting, ensure the following tools are installed and configured:

- **Terraform**: Infrastructure as Code tool.
- **AWS CLI**: For managing AWS services.
- **kubectl**: Kubernetes CLI tool.
- **Helm**: Kubernetes package manager.
- **Docker**: For containerizing and pushing images.

Also, ensure that AWS credentials are configured in your environment.

---

## Steps to Deploy the Infrastructure

### 1. Create Infrastructure with Terraform

```bash
# Navigate to the Terraform directory
cd terraform

# Initialize Terraform
terraform init

# Apply the Terraform configuration to create all resources
terraform apply -auto-approve
```
Terraform provisions the following resources:
- **EKS Cluster**
- **IAM Roles**
- **VPC and Subnets**
- **ECR Repos**
- **Ingress Nginx**
- **Jenkins**

### 2. Build and Push Docker Images to ECR
```bash
# Log in to AWS Elastic Container Registry (ECR)
aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.<your-region>.amazonaws.com

# Build the Docker image
docker build -t <your-ecr-repo-url>/jenkins:latest .

# Push the Docker image to ECR
docker push <your-ecr-repo-url>/jenkins:latest
```

### 3. Update the Jenkinsfile with Correct Values
```groovy
    environment {
        ECR_REPO_URL = "<your-ecr-repo-url>"
    }
```

```yaml
# Log in to AWS Elastic Container Registry (ECR)
pipeline {
    agent {
        kubernetes {
            yaml """
            apiVersion: v1
            kind: Pod
            metadata:
              labels:
                some-label: some-value
            spec:
              containers:
              - name: jnlp
                image: <your-ecr-repo-url>:latest
                args: ['\$(JENKINS_SECRET)', '\$(JENKINS_AGENT_NAME)']
            """
        }
    }
}
```

### 4. Get the Load Balancer DNS Name
```bash
    # Get the value from the Ingress Resource
    kubectl get ingress -n ingress-nginx
```

or use the AWS Management Console to get the DNS name of the Load Balancer

### 5. Access the Applications
Use the load balancer’s DNS name to access the deployed services:
-	**Application: http://{load-balancer-dns-name}/movies**
-	**Jenkins: http://{load-balancer-dns-name}/jenkins**
-	**Grafana: http://{load-balancer-dns-name>}/grafana**