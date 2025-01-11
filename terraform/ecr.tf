resource "aws_ecr_repository" "services" {
  for_each = toset(var.services)
  name     = each.key

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "jenkins" {
  name     = "jenkins"

  image_scanning_configuration {
    scan_on_push = true
  }
}