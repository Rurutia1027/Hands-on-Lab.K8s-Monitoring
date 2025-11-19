# Kubernetes Monitoring Architecture -- Node/Pod/Application/Cluster Layers 

## Overview of Kubernetes Monitoring 
Kubernetes monitoring is built around the flow: 

### Metric Collectors 
Collect metrics from different Kubernetes layers (node, pod, application, control plane). 

### Metrics Storage 
Prometheus stores all collected metrics in a **time-series database (TSDB)**. 

### Metrics Querying & Visualization 
Grafana reads data from Prometheus and displays dashboards. 

### Alerting 
Alertmanager receives Prometheus alerts and sends notifications. 

Monitoring helps understand: 
- Node and hardward health 
- Pod performance 
- Application-level behavior 
- Control plane stability 
- Troubleshooting and SRE alerting 

Dashboards and metrics are usually organized by **Node**, **Pod**, **Application**, and **Cluster** layers. 

---

## Node Layer Monitoring 
Node-level monitoring focuses on OS, hardware, and kubelet signals. 

### Node Exporter 
**Type**: Third-party 
**Deployment**: DaemonSet(1 per node)
**Endpoint**: `http://node-exporter:9100/metrics`

**Purpose**: Standard Linux node monitoring. 

**Metrics collected**: 
- CPU usage (user/system/idle)
- Memory usage (available/used/buffers/cache)
- Disk I/O (read/write bytes, IOPS)
- Filesystem usage (% used)
- Network throughput & errors
- Hardware info (CPU model, cores)

Why needed: 
Node Exporter collected metric indicators provide core node hardware and OS metrics for dashboards and troubleshooting. 


### cAdvisor (Container Advisor)
**Type**: Native (built into Kubelet)
**Deployment**: No extra pods needed
**Endpoint**: Exposed through kubelet metrics pipeline 

**Metrics collected**: 
- Per-container CPU & memory usage
- Container filesystem usage 
- Container processes 
- Container performance data 

Why needed: 
Fundamental for pod/container resource metrics. 

### Kubelet Metrics 
**Type**: Native 
**Endpoint**: `/metrics`

**Metrics collected**:
- Node conditions 
- Pod lifecycle events
- Image info 
- Runtime info (containerd/docker)
- Kubelet performance 
- Pressure metrics (disk, memory, PID)

Why needed: 
Critical health signals for node and runtime behavior 


--- 

## Pod/Application Layer Monitoring 
This layer covers pod states, workload behavior, and application-level performance. 

### kube-state-metrics (KSM)
**Type**: Third-party 
**Deployment**: Deployment 
**Endpoint**: `http://kube-state-metrics.monitoring.svc:8080/metrics`
**Metrics collected**(cluster state, not CPU/memory):
- Deployment replica counts
- StatefulSets / DaemonSets states 
- Node labels, taints
- Pod phases: Pending / Running / Succeeded / Failed 
- PersistentVolume states 
- Service / Ingress state 

**Why needed**: 
Provides the logical state-not performance -- for SRE alerts such as: 
- Deployment unavailable
- Pod CrashLoopBackOff 
- Node NotReady 

### Application Instrumentation (Prometheus Client Libraries)
**Type**: Third-party (app exposes its own `/metrics`)
**Endpoint**: `http://<pod-ip>:8080/metrics` (or app-defined)



