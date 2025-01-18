variable "region" {
  description = "AWS region"
  type = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  default     = "cinema-eks"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
}

variable "services" {
  description = "Services name for creating ECR Repo"
  default = ["movies-service", "jenkins"]
}