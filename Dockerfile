FROM --platform=linux/amd64 amazonlinux:2

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && yum install -y unzip \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip ./aws

# Install Docker
RUN amazon-linux-extras enable docker \
    && yum install -y docker \
    && yum clean all