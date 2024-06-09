variable "jenkins_values" {
  type    = string
  default = <<EOF
    controller:
      service:
        type: LoadBalancer
      jenkinsHome: "/var/jenkins_home"
      admin:
        username: admin
        password: admin
      installPlugins:
        - kubernetes:1.29.7
        - workflow-aggregator:2.6
        - git:4.7.2
        - google-oauth-plugin:1.330.vf5e86021cb_ec
      securityRealm:
        local:
          allowsSignup: false
      authorizationStrategy: loggedInUsersCanDoAnything
      volumes:
        - name: gcp-key
          secret:
            secretName: gcp-key
      volumeMounts:
        - name: gcp-key
          mountPath: gcp-credentials.json
          readOnly: true
  persistence:
    enabled: true
    storageClass: "standard"
    accessMode: "ReadWriteOnce"
    size: "8Gi"
    EOF
}

resource "helm_release" "jenkins" {
  name             = "jenkins"
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  version          = "5.1.30"
  cleanup_on_fail  = true
  namespace        = "jenkins"
  create_namespace = true

  values = [var.jenkins_values]

  depends_on = [google_container_cluster.primary]
}

resource "kubernetes_secret" "gcp_key" {
  metadata {
    name      = "gcp-key"
    namespace = "jenkins"
  }

  data = {
    "key.json" = filebase64("gcp-credentials.json")
  }

  depends_on = [helm_release.jenkins]
}