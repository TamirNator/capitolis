# IAM Role for Jenkins Service Account
resource "aws_iam_role" "jenkins_service_account_role" {
  name               = "jenkins-service-account-role"
  assume_role_policy = data.aws_iam_policy_document.jenkins_service_account_assume_role_policy.json
}

data "aws_iam_policy_document" "jenkins_service_account_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:jenkins:default"]
    }
  }
}

resource "aws_iam_policy" "eks_policy" {
  name        = "EKS-Policy"
  description = "Policy to allow Actions for EKS"
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowEC2"
        Effect   = "Allow",
        Action   = [
          "ec2:CreateVolume",
          "ec2:CreateTags",
          "ec2:CreateSnapshot",
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:ModifyVolume",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInstances",
          "ec2:DescribeSnapshots",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumesModifications"
        ],
        Resource = "*"
      },
      {
        "Sid": "AllowECR",
        "Effect": "Allow",
        "Action": [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ],
        "Resource": "*"
      },
      {
        "Sid": "AllowRout53",
        "Effect": "Allow",
        "Action": [
          "route53:ChangeResourceRecordSets",
          "route53:ListHostedZonesByName",
          "route53:ChangeResourceRecordSets",
          "route53:GetChange"
        ],
        "Resource": "*"
      }
    ]
  })
}