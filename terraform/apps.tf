resource "helm_release" "jenkins" {
  name       = "jenkins"
  chart      = "jenkins"
  repository = "https://charts.jenkins.io"
  namespace  = "jenkins"
  create_namespace = true
  set {
    name = "persistence.storageClass"
    value = "gp2"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.jenkins_service_account_role.arn
  }
  set {
    name  = "controller.service.annotations.alb\\.ingress\\.kubernetes\\.io/target-type"
    value = "ip"
  }

  set {
    name  = "controller.service.annotations.alb\\.ingress\\.kubernetes\\.io/healthcheck-path"
    value = "/"
  }

  set {
    name  = "controller.service.annotations.alb\\.ingress\\.kubernetes\\.io/healthcheck-port"
    value = "8080"
  }
  set {
    name  = "controller.resources.requests.cpu"
    value = "500m"
  }
  set {
    name  = "controller.resources.requests.memory"
    value = "512Mi"
  }
  set {
    name  = "controller.resources.limits.cpu"
    value = "750m"
  }
  set {
    name  = "controller.resources.limits.memory"
    value = "768Mi"
  }
  set {
    name  = "controller.javaOpts"
    value = "-Xmx512m -Xms256m"
  }
  set {
    name  = "controller.serviceType"
    value = "NodePort"
  }
  set {
    name  = "controller.jenkinsUriPrefix"
    value = "/jenkins"
  }
  depends_on = [ module.eks ]
}