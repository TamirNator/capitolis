FROM --platform=linux/amd64 amazonlinux:2

# Install system tools
RUN yum update -y && yum install -y \
    curl \
    unzip \
    tar \
    gzip \
    python3 \
    && yum clean all

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip ./aws

# Install Docker
RUN amazon-linux-extras enable docker \
    && yum install -y docker \
    && yum clean all

# Install kubectl
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/

# Install Helm
RUN curl -LO "https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz" \
    && tar -xzf helm-v3.12.0-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && rm -rf helm-v3.12.0-linux-amd64.tar.gz linux-amd64