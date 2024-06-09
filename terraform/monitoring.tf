variable "kube_monitoring_stack_values" {
  type    = string
  default = <<-EOF
    grafana:
      adminUser: admin
      adminPassword: admin
      enabled: true
      service:
        type: LoadBalancer
      ingress:
        enabled: false
      resources:
        requests:
          cpu: "100m"
          memory: "100Mi"
        limits:
          cpu: "200m"
          memory: "200Mi"

    alertmanager:
      alertmanagerSpec:
        replicas: 2  # Number of Alertmanager replicas for clustering
        clusterPeerTimeout: 15s
        clusterListenAddress: "0.0.0.0:9093"
        clusterPeers:  
          - kube-prometheus-stack-alertmanager.alertmanager.monitoring.svc:9093
      enabled: true
      service:
        type: LoadBalancer
      ingress:
        enabled: false
      resources:
        requests:
          cpu: "100m"
          memory: "100Mi"
        limits:
          cpu: "200m"
          memory: "200Mi"

    prometheus:
      ingress:
        enabled: false
      service:
        type: LoadBalancer
      prometheusSpec:
        replicas: 2
        replicaExternalLabelName: prometheus_replica
        prometheusExternalLabelName: prometheus_cluster
        enableAdminAPI: false
        logFormat: logfmt
        logLevel: info
        retention: 120h
        serviceMonitorSelectorNilUsesHelmValues: false
        serviceMonitorNamespaceSelector: {}
        serviceMonitorSelector: {}
      resources:
        requests:
          cpu: "100m"
          memory: "100Mi"
        limits:
          cpu: "200m"
          memory: "200Mi"

    prometheus-node-exporter:
      resources:
        requests:
          cpu: "80m"
          memory: "100Mi"
        limits:
          cpu: "160m"
          memory: "200Mi"

    kube-state-metrics:
      resources:
        requests:
          cpu: "100m"
          memory: "100Mi"
        limits:
          cpu: "200m"
          memory: "200Mi"

    prometheusOperator:
      resources:
        requests:
          cpu: "100m"
          memory: "100Mi"
        limits:
          cpu: "200m"
          memory: "200Mi"
          
    prometheusRule:
      additionalPrometheusRules:
        - name: custom-alert-rules
          groups:
            - name: custom.rules
              rules:
                - alert: TargetDown
                  expr: 100 * (count by (job, namespace, service) (up == 0) / count by (job, namespace, service) (up)) > 10
                  for: 10m
                  labels:
                    severity: warning
                  annotations:
                    description: '{{ printf "%.4g" $value }}% of the {{ $labels.job }}/{{ $labels.service }} targets in {{ $labels.namespace }} namespace are down.'
                    runbook_url: https://runbooks.prometheus-operator.dev/runbooks/general/targetdown
                    summary: One or more targets are unreachable.
    EOF
}

resource "helm_release" "kube_monitoring_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  version          = "45.29.0"
  create_namespace = true
  values           = [var.kube_monitoring_stack_values]
}
