# Node-Level Metrics Collectors (Node, OS, Hardward)

## Node Exporter (Prometheus Node Exporter)
What it collects: 
- CPU usage (user/system/idle)
- Memory usage (available/used/buffers/cache)
- Disk I/O (read/write bytes, IOPS)
- Filesystem usage (volume % used)
- Network throughput & errors
- Hardware info (CPU model, core count)

Why it's used 
This is de facto standard for Linux node monitoring.
Runs as a **DaemonSet** -- 1 instance per node. 

## cAdvisor (Container Advisor)
What it collects: 
- Per-container CPU & memory usage 
- Container filesystem usage 
- Container processes 
- Container-level performance data 

Why it's used: 
It is built into the **kubectl**, so it is the fundamental tool for pod + container resource metrics. 


## Kubelet Metrics Endpoint (`/metrics`)
What it collects: 
- Node conditions
- Pod lifecycle events
- Images, runtiems info 
- Kubelet performance metrics 
- Runtime metrics from containerd/docker 

Why it's used
Prometheus scrapes this endpoint directly and it is essential for cluster health signals like: 
- Disk pressure 
- Memory pressure 
- PID pressure 


# Pod/Application-Level Metrics Collectors 

## kube-state-metrics (KSM)
What it collects: 
State of Kubernetes objects (NOT CPU/memory):
- Deployments (replicas, availability)
- StatefulSets, DaemonSets
- Nodes (labels, taints)
- Pods (phase: Pending/Running/Succeeded/Failed)
- PersistentVolumes state 
- Ingress & Service state 


Why it's used: 
It provides the logical state of the cluster, not resource metrics. 
Critical for SRE alerts and dashboards - e.g.,: 
- Deployment has 0 available replicas
- Pod stuck in CrashLoopBackOff
- Node marked NotReady

## Application Instrumentation (Prometheus client libraries)
Our workloads can expose **custom metrics** such as: 
- Request QPS
- Request latency (p99)
- Error rate 
- Cache hit ratio
- Business metrics (order, payments)

Why it's used: 
SREs need SLO/SLA metrics -> request latency, error %

## ServiceMesh Metrics (optional)
If you deploy a service mesh (Istio, Linkerd):
You get automatic: 
- Request throughput
- Request latency 
- Error rates
- mTLS handshake metrics 
- Connection stats

Collected via Envoy sidecards


# Control Plane Component Metrics Collectors 

Control-plane components expose `/metrics endpoints` internally.

These are scraped by Prometheus (usually through ServiceMonitors). 


## API Server Metrics 
What it collects: 
- Request rate
- Request latency 
- Request error rate 
- Audit events
- Admission webhook duration 
- Etcd communication metrics 

Why it's used: 
API server is the **heartbeat** of Kubernetes. 

Alerts like: 
- API server latency > 1s
- Too many 429 throttling errors
- etcd write operations slow 


## Controller Manager Metrics 
What it collects: 
- Deployment collector sync duration 
- ReplicaSet controller activity 
- Job controller metrics 
- HorizontalPodAutoscaler (HPA) metrics
- Work queue metrics 

Why it's used: 
- Shows when control plane logic is stuck 
- Critical for diagnosing cluster-wide issues. 

## Scheduler Metrics 
What it collects: 
- Scheduling latency
- Scheduling failures 
- Pod unschedulable reasons 
- Queue depth metrics 

## Etcd Metrics 
What is does: 
- Leadership change frequency 
- Commit latency 
- Disk IOPS 
- Number of watchers 
- WAL fsync durations 

Why it's used: 
Etcd performance directly affects: 
- API Server latency
- Cluster reliability 
- Data consistency 


---

# Cluster-Wide Aggregated Collectors 
## Prometheus Server 
What it does:
- Scrapes all metrics endpoints
- Stores timeseries
- Executes queries 
- Sends alerts to Alertmanager 

Why it's used: 
- Prometheus is the **core foundation** of all K8s monitoring. 

## Alertmanager 
What it does 
- Receive Prometheus alerts 
- Groups alerts 
- Sends notifications (Slack, email, PagerDuty)

## Grafana 
What it does 
- Visualize metrics from Prometheus
- Dashboards for nodes, pods, control plane 

Grafana doesn't collect metrics -- it only displays them. 


Here is a brief Kubernetes Metrics Collector - With Data Source Endpoints info 

----

Here is a brief introduct of Kubernente native vs. Third Party 


#### Node Exporter 
- Third-party 
- DaemonSet installed in cluster, not built-in. 

#### cAdvisor 
- Native 
- Built into Kubelet, no extra Pod required 

#### kube-state-metrics 
- Third-party 
- Must deploy separately (Deployment)


### App client libraries 
- Third-party 
- Application exposes metrics endpoints. 

### Service Mesh metrics 
- Third-party 
- Sidecar injected 

### APIServer/Scheduler/Controller/etcd 
- Native 
- Core Kubernentes components expose `/metrics` directly 



There are two modes for Prometeus fetch the metric data streams 

Pull vs. Push 

- Pull = Promtheus scrapes the endpoint (most common)
- Push = Only for apps that cannot expose `/metrics` -> use Pushgateway 
Endpoint Mappint of Prometheus 

#### Node Exporter 
`http://node-exporter-node1:9100/metrics`

#### kube-state-metrics 
`http://kube-state-metrics.monitoring.svc:8080/metrics`


#### API Server 
`https://kube-apiserver:6443/metrics`


#### Controller Manager 
`http://controller-manager:10252/metrics`

#### Scheduler
`http://kube-scheduler:10251/metrics`

#### etcd 
`https://etcd:2379/metrics`

#### App Pod 
`http://<pod-ip>:8080/metrics`

#### Envo Sidecar 
`http://<pod-ip>:15090/stats/prometheus`


-- 

Definition of Promethues 

Prometheus is the core monitoring system used in Kubernentes. 
It collects metrics from nodes, pods, containers, and applications by pulling (scraping) data from HTTP endpoints. 

It stores this data/metric data collected from different metric compoentns endpoints(must be HTTP protoco) in a time-series database and lets you query it using PromQL for alerting and visualizing . 

<Add Prometheus architecutre diagram here> 

Prometheus TSDB -> Time series -> Optimized for metrics data that changes over time. 

NoSQL Database -> Optimized for unstructured or semi-strctured data. 

RDBMS -> Optimized for structure data and ACID transactions. 

---
