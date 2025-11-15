# Kubernetes Cluster Monitoring Stack 
## Project Overview 

This repository offers a comprehensive solution for setting up a local Kubernetes development environment with a robust monitoring stack. It is designed to:
- Enable developers to quickly spin up a Kind-based local K8s cluster (1 master + 2 workers).
- Minimize gaps between local, testing, and production environments, reducing bugs caused by environment differences.
- Provide **deep insights into K8s components**, including logs, metrics, and SLA/KPI indicators.
- Support **troubleshotting and performance analysis**, helping architects make informed trade-offs and decisions.
- Serve as a **foundation for advanced experiments**, such as Istio service mesh, traffic management validation, and security testing.

## Key Features 
### Complete Monitoring Stack (Manifest-Based Deployment)
- Node Exporter & cAdvisor (Node/Container metrics)
- kube-state-metrics (Kubernetes object state)
- Prometheus (metrics collection & storage)
- Grafana (dashboard visualization)
- Alertmanager (optional alerts)

### Metrics & SLA/KPI Focus 
- Node: CPU, memory, disk I/O, network throughput, Kubelet health
- Pod/Deployment: Pod lifecycle, container CPU/memory, restart counts
- Application: Business metrics, request latency, throughput, queue/job stats
- Control-plane: API Server QPS, latency, errors; Scheduler & Controller Manager performance; etcd WAL latency & commit rate
- Network: Pod-to-Pod/Node-to-Node latency, throughput, packet loss

### Health & Endpoint Checks 
- Predefined shell script verifies **component readiness** and **metrics endpoint availability**, ensuring safe subsequent configuration.

### One-Stop Deployment 
- All components are deployed using **pure YAML manifests**, no Helm dependency.
- Scripts and manifests organized for **modular** and **reusable deployment**. 

## Directory Structure 
```
monitoring-stack/
├── manifests/          # YAML manifests for all components
│   ├── namespace.yaml
│   ├── node-exporter-daemonset.yaml
│   ├── cadvisor-daemonset.yaml
│   ├── kube-state-metrics/
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   ├── prometheus/
│   │   ├── configmap.yaml
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   ├── grafana/
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   └── alertmanager/
│       ├── configmap.yaml
│       └── deployment.yaml
├── scripts/            # Helper scripts
│   ├── start-kind-cluster.sh          # Script to launch a local Kind cluster (1 master + 2 workers)
│   ├── wait-cluster-ready.sh          # Script to wait until cluster components (API server, kubelet, etcd) are ready
│   └── monitoring-health-check.sh     # Script to check monitoring stack pods and metrics endpoints
└── design-doc/         # Metrics & SLA/KPI design, dashboard plans
    └── metrics-design.md
```

## Deployment Order 
- Deploy a Kubernetes Cluster via Kind
- Deploy **Node Exporter** & **cAdvisor DaemonSets**
- Deploy **kube-state-metrics Deployment + Service**
- Deploy **Prometheus ConfigMap** + **Deployment** + **Service**
- Deploy **Grafana Deployment + Service**
- Optionally deploy **Alertmanager**

## Metrics Design & Dashboard 

#### Each component has **core KPIs** and **SLA indicators** captured via Prometheus.
#### **Dashboard design**(Grafana) includes:

- Node: CPU, memory, disk, network utilization, Ready status
- Pod/Deployment: Pod lifecycle, container resource consumption, restart history
- Application: Latency, TPS, error rates, queue/job stats
- Control-plane: API Server QPS/latency/errors, Scheduler & Controller Manager metrics, etcd performance
- Network: Pod/Node network latency, throughput, packet loss

#### Metrics are labeled with `node`, `namespace`, and `pod` to enable aggregation and slicing.
#### Health-check scripts validate endpoints before enabling dashboards 

## Usage 

### Step 1: Apply all manifests:
```bash
kubectl apply -f manifests/
```

### Step 2: Run health-check script: 
```bash
scripts/monitoring-health-check.sh
```

### Step 3: Access dashboards:
- Prometheus: `http://localhost:30090`
- Grafana: `http://localhost:30300`

## Future Extensions
- Add **application-specific metrics** and example workloads
- Configure **Prometheus scrape targets** and **AlertManager** rules
- Extend dashboards for **network metrics** and **service mesh validation**
- Use as a **testbed for Istio and advanced traffic management experiments**

