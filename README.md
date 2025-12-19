# Observability Stack on Kubernetes Kind (Prometheus + Grafana) | [![CI - Kubernetes Kind & Monitoring Validation](https://github.com/Rurutia1027/Hands-on-Lab.K8s-Monitoring/actions/workflows/ci-k8s.yml/badge.svg)](https://github.com/Rurutia1027/Hands-on-Lab.K8s-Monitoring/actions/workflows/ci-k8s.yml)

This repository provides a streamlined, reproducible environment for building and validating a complete Observability Stack on a local Kind Kubernetes cluster.
It focuses on Prometheus-based metrics collection and Grafana visualization, using Helm for deployment.

The repo is intended for engineers who want a clean, automated baseline for metrics observability before integrating TLS, Vault PKI, or enterprise configurations.

## Repository Layout

```
.
├── configs/
│   └── kind-config.yaml            # Kind cluster topology and port mappings
├── helm/
│   ├── grafana-values.yaml         # Grafana Helm overrides
│   └── prometheus-values.yaml      # Prometheus Helm overrides
├── setup-k8s-cluster.sh            # Create Kind cluster + deploy Prometheus & Grafana
├── shutdown-k8s-cluster.sh         # Clean shutdown of the environment
└── README.md
```

## Core Workflow (Local Usage)
### Create the Observability Environment 
```
bash setup-k8s-cluster.sh
```

This script:

- Creates a Kind cluster using configs/kind-config.yaml
- Installs Prometheus & Grafana via Helm
- Waits for all Pods / Deployments / NodePorts to become Ready
- Prints out:
> Prometheus NodePort URL
> Grafana NodePort URL

### Access the Stack
- Prometheus 
```
http://localhost:<prometheus-nodeport>
```

- Grafana 
```
http://localhost:<grafana-nodeport>
```

### Tear Down 
```
bash shutdown-k8s-cluster.sh
```

## Extend This Repository

You can incrementally add:

### Optional Enhancements

- Vault PKI for Prometheus/Grafana TLS
- Ingress with HTTPS termination
- Loki + Promtail (logging)
- Tempo or Jaeger (tracing)
- Dashboard-as-Code (ConfigMaps or Grafana Provisioning)
- Additional Prometheus exporters (etcd, API server, kube-controller-manager)
