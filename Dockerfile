FROM amazonlinux:2 as installer
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN yum update -y \
  && yum install -y unzip \
  && unzip awscliv2.zip \
  && ./aws/install --bin-dir /aws-cli-bin/

RUN curl -sS -L https://github.com/gruntwork-io/terragrunt/releases/download/v0.45.4/terragrunt_linux_amd64 -o ./terragrunt \
  && chmod +x ./terragrunt \
  && mv ./terragrunt /usr/local/bin

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod u+x ./kubectl
RUN mv ./kubectl /usr/local/bin


RUN curl https://releases.hashicorp.com/terraform/1.4.5/terraform_1.4.5_linux_amd64.zip -o terraform_1.4.5_linux_amd64.zip \
  && unzip terraform_1.4.5_linux_amd64.zip \
  && mv terraform /usr/local/bin \
  && rm terraform_1.4.5_linux_amd64.zip


RUN curl -sS -L https://github.com/mikefarah/yq/releases/download/v4.33.3/yq_linux_amd64 -o /usr/local/bin/yq \
  && chmod +x /usr/local/bin/yq

RUN curl https://get.helm.sh/helm-v3.12.0-linux-amd64.tar.gz -o /usr/local/bin/helm-v3.11.0-linux-amd64.tar.gz \
    && yum install -y gzip \
    && yum install -y tar \
    && tar xfz /usr/local/bin/helm-v3.11.0-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin/

    RUN amazon-linux-extras enable docker \
    && yum install -y docker \
    && docker --version || true

# Clean up
RUN yum clean all && rm -rf /var/cache/yum

FROM --platform=linux/amd64 jenkins/inbound-agent:latest
COPY --from=installer /usr/bin/docker /usr/bin/docker
COPY --from=installer /usr/local/aws-cli/ /usr/local/aws-cli/
COPY --from=installer /aws-cli-bin/ /usr/local/bin/
COPY --from=installer /usr/local/bin/kubectl /usr/local/bin/kubectl
COPY --from=installer /usr/local/bin/terraform /usr/local/bin/terraform
COPY --from=installer /usr/local/bin/terragrunt /usr/local/bin/
COPY --from=installer /usr/local/bin/yq /usr/local/bin/
COPY --from=installer /usr/local/bin/helm /usr/local/bin/