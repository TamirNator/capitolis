variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  default     = "cinema-cluster"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/24"
}

variable "services" {
  default = ["movies-service", "user-service", "booking-service", "showtimes-service"]
}