resource "kubernetes_role_binding" "jenkins_role_binding" {
  metadata {
    name      = "jenkins-dev-role-binding"
    namespace = "jenkins"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "jenkins-dev-role"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "jenkins"
    api_group = ""
  }
  depends_on = [ helm_release.jenkins ]
}

resource "kubernetes_role" "jenkins_role" {
  metadata {
    name = "jenkins-dev-role"
    namespace = "jenkins"
  }
  rule {
    api_groups     = [""]
    resources      = ["pods", "secrets", "serviceaccounts"]
    verbs          = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["get", "list"]
  }
  depends_on = [ helm_release.jenkins ]
}

resource "kubernetes_role_binding" "dev_role_binding" {
  metadata {
    name      = "eks-dev-role-binding"
    namespace = "default"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.dev_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "jenkins"
    api_group = ""
  }
}

resource "kubernetes_role" "dev_role" {
  metadata {
    name = "eks-dev-role"
    namespace = "default"
  }
  rule {
    api_groups     = [""]
    resources      = ["pods", "secrets", "serviceaccounts", "services"]
    verbs          = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}
# Define the ClusterRole
resource "kubernetes_cluster_role" "node_role" {
  metadata {
    name = "node-role"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "pods/exec"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "node_role_binding" {
  metadata {
    name = "node-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.node_role.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "system:nodes"
    api_group = "rbac.authorization.k8s.io"
  }
}