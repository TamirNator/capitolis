FROM --platform=linux/amd64 amazonlinux:2023

# Install system tools
RUN dnf install -y \
    unzip \
    tar \
    gzip \
    python3 \
    python3-pip \
    docker \
    && dnf clean all


RUN python3 -m pip install safety==1.10.3 pytest

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip ./aws

# Install kubectl
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.27.0/bin/linux/amd64/kubectl" \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/

# Install Helm
RUN curl -LO "https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz" \
    && tar -xzf helm-v3.12.0-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && rm -rf helm-v3.12.0-linux-amd64.tar.gz linux-amd64

# Set working directory
WORKDIR /app