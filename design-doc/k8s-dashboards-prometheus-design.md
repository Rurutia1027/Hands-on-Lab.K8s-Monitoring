# K8s Cluster Metrics Dashboards Design 

## Overview 
This documentation defines the structure, indicators, calculation methods, and visualization types for Kubernentes monitoring dashboards used by SRE and DevOps teams. 
Dashboards are organized using a **top-down troubleshooting hierarchy**, starting with SLO/user experiences, and drilling down into application, control-plane, and node layers. 

The objectives are: 
- Fast incident detection
- Rapid root-cause analysis 
- Component-oriented visibility 
- Clear status communication to engineers


## Dashboard Architectures 

We adopt a 5-layer model: 
- SLO/User Experience Dashboard 
- Service / Traffic Dashboard (RED metrics)
- Workload / Application Dashboard 
- Control Plane Dashboard 
- Node / Infrastructure Dashboard 

Each dashboard contains: 
- Indicators (metrics)
- PromQL formulas
- Interpretation (what the metric reflects)
- Visualization type 

```
[Top]     SLOs (user-facing)
          ↓
          Services (requests, latency, errors)
          ↓
          Workloads (pods, deployments)
          ↓
          Control plane (API, scheduler, etcd)
          ↓
[Bottom]  Nodes (CPU, memory, disk, network)

```

## Layer 0 -> SLO/User Experience Dashboard 
This top-level dashboard answers: 
"Are our users experiencing pain?"

### A1. Latency (P99/P95/P50)
**Formula**
```scss
histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))
```

**Interpretation**
- Measures **end-to-end API responsiveness**
- Reflects **user-perceived performance**

**Visualization**
- **Line chart**(time series)
- Optionally **heapmap** for latency buckets

### A2. Error Rate 
**Formula**
```scss
sum(rate(http_requests_total{status=~"5.."}[5m]))
/
sum(rate(http_requests_total[5m]))
```

**Interpretation**
- High error rate = degraded service quality
- Used for **SLO burn rate** alerts

**Visualization**
- **Line chart**(time series)
- **Single-value gauge** ("Error %")


### A3. Availability%

**Formula**
```
1 - (
  sum(rate(http_requests_total{status=~"5.."}[5m]))
  /
  sum(rate(http_requests_total[5m]))
)
```
**Interpretation**
- Core service availability 
- ties directly to SLO error budget 

**Visualization**
- Big number panel 
- Green/Yellow/Red coloring 


### A4. SLO Burn Rate 

**Formula**
```
increase(error_total[1h]) / allowed_error_budget_per_hour
```

**Interpretation**
- How fast the system is burning SLO
- Critical for SRE management decisions 

**Visualization**
- Line chart 
- Colored threshold bands 

## Dashboard B -- service Traffic (RED Metrics)
_Focus: Requests, Errors, Duration_
_Align with Google SRE Golden Signals_

### B1. Request Rate (RPS)

**Formula**
```
sum(rate(http_requests_total[1m])) by (service)
```

**Interpretation**
- Traffic load per service
- Identifies hotspots or sudden spikes 

**Visualization**
- Line chart 
- Per-service groups 

### B2. Error Rate (4xx/5xx)

**Formula**
```
sum(rate(http_requests_total{status=~"5.."}[1m])) by (service)
```

**Interpretation**
- Application-level health 
- Routing, ingress, or microservices logic failures

**Visualization**
- Stacked area chart to show error distribution 
- Dedicated 5xx spike alert panel 

### B3. Latency Distribution 
**Formula**
Use histogram_quantile for P50/P95/p99 as earlier.

**Interpretation**
- Service execution quality 
- Detects tail latency issues 

**Visualization**
- Three line charts (P50/P95/P99)
- Option: Latench histogram 

### B4. Ingress Controller Indiciators 
**RPS**
```
sum(rate(nginx_ingress_controller_requests[1m])) by (ingress)
```

**Request latencies**
```
histogram_quantile(0.99, sum(rate(nginx_ingress_controller_request_duration_seconds_bucket[5m])) by (le))
```

**Interpretation**
- Entry point health
- Detects client-side or network-side problems 

**Visualization**
- Line chart 
- Bar chart for top N slow ingresses 


## Dashboard C -- Workload / Application Dashboard 
_Focus: Pods, Deployments, HPA, CronJobs_
_Source: Kube-State-Metrics + cAdvisor_

### C1. Pod CPU Usage vs Requests 
**Formula**
- Usage: 
```
sum(rate(container_cpu_usage_seconds_total{image!="",container!="POD"}[5m])) by (pod)
```

- Request: 
```
sum(kube_pod_container_resource_requests_cpu_cores) by (pod)
```

**Interpretation**
- Detect resource pressure 
- Detect under-requested or over-requested containers 

**Visualization**
- Bar chart (stacked)
- Line chart (usage vs request)


### C2. Pod Memory Usage vs Limits 

**Formula**
```
container_memory_working_set_bytes
/
kube_pod_container_resource_limits_memory_bytes
```

**Interpretation**
- Detect OOM risks 
- Unbalanced memory allocation 

**Visualization**
- Gauge (danger zone above 90%)
- Top N memory pods table 

### C3. Pod Restart Count 

**Formula**
```
rate(kube_pod_container_status_restarts_total[5m])
```

**Interpretation**
- CrashLoopBackOff, OOMKill, image pull failures 
- 90% of workload issues show up here first 


**Visualization**
- Table (sorted descending)
- Single-value counters 

### C4. Deployment Health 
**Formula**
```
kube_deployment_status_replicas_available
/
kube_deployment_status_replicas
```

**Interpretation**
- Rollout stuck ? 
- Missing replicas ? 

**Visualization**
- Heatmap 
- Green/Red status table 


### C5. HPA Scaling Behavior 
**Formula**
```
kube_hpa_status_current_replicas
kube_hpa_status_desired_replicas
```

**Interpretation**
- Detect wrong thresholds 
- Identify scaling lag 

**Visualization**
- Line chart showing replicas movement 


## Dashboard D -- Control Plane Dashboard 
_Focus: API Server, Scheduler, Controller-Manager, etcd_

### D1. API Server Request Latency 
**Formula**
```
histogram_quantile(0.99, sum(rate(apiserver_request_duration_seconds_bucket[5m])) by (le, verb))
```

**Interpretation**
- Slowness may affect all workloads 
- Often tied to etcd latency 

**Visualization**
- Line chart 
- Verb breakdown pie chart (GET/POST/WATCH)

### D2. API Server Error Rate 
**Formula**
```
sum(rate(apiserver_request_total{code=~"5.."}[5m])) by (verb)
```

**Interpretation**
- Admission webhooks errors 
- RBAC issues 
- Network/etcd slowness 


**Visualization**
- Stacked area chart 

### D3. Scheduler Latency 
**Formula**
```
histogram_quantile(0.99, sum(rate(scheduler_e2e_scheduling_latency_seconds_bucket[5m])) by (le))
```

**Interpretation**
- High latency -> pending pods 
- Often caused by resource pressure or taints 

**Visualization**
- Line chart (p99)

### D4. etcd Fsync Duration 
**Formula**
```
histogram_quantile(0.99, rate(etcd_disk_wal_fsync_duration_seconds_bucket[5m]))
```

**Interpretation**
- etcd disk bottleneck 
- Primary cause of API latency 

**Visualization**
- Line chart (p99)


### D5. etcd Leader Changes 
**Formula**
```
increase(etcd_server_leader_changes_seen_total[5m])
```

**Interpretation**
- Frequent changes -> unstable cluster 
- Often due to network issues 

**Visualization**
- Bar chart 

## Dashboard E - Node / Infrastructure Dashboard 
_Focus: Node exporter + kubelet metrics_

### E1. CPU Saturation 
**Formula**
```
sum(rate(node_cpu_seconds_total{mode="idle"}[5m])) by (instance)
```

Invert to saturation
```
1 - idel_ratio
```

**Interpretation**
- CPU pressure 
- No room for new workloads 

**Visualization**
- Line chart
- Per-node bar chart 


### E2. Memory Pressure 
**Formula**
```
node_memory_MemAvailable_bytes
/
node_memory_MemTotal_bytes
```

Invert to pressure: 
```
1 - availability
```

**Interpretation**
- Node-level memory pressure 
- Kubelet eviction risk 

**Visualization**
- Gauge 
- Heatmap 


### E3. Disk I/O Latency 
**Formula**
```
rate(node_disk_read_time_seconds_total[5m])
/
rate(node_disk_reads_completed_total[5m])
```

**Interpretation**
- Critical for etcd and workload performance 
- Predict disk failures 

**Visualization**
- Line chart 

### E4. Node Network Drops 
**Formula**
```
rate(node_network_receive_drop_total[5m])
```

**Interpretation**
- Often indicates NIC or kernel issues
- Can break pod networking 

**Visualization**
- Stacked area chart 

### E5. Kubelet Health 
**Formula**
API Request Latency: 
```
rate(rest_client_request_duration_seconds_sum{job="kubelet"}[5m])
```

**Interpretation**

- Show kubelet -> pod scheduling/eviction problems 

**Visualization**
- Line chart 


## Dashboard Layout 
```
Dashboard A: SLO Overview
   - Latency p99
   - Error %
   - Availability %
   - SLO burn rate

Dashboard B: Service Traffic
   - RPS
   - 4xx/5xx
   - Latency histograms
   - Ingress metrics

Dashboard C: Workload Health
   - Pod CPU/mem usage
   - Pod restarts
   - Deployment rollout status
   - HPA scaling behavior

Dashboard D: Control Plane
   - API server latency
   - Scheduler latency
   - Controller Manager queue depth
   - etcd fsync + leader changes

Dashboard E: Node / Infra
   - CPU saturation
   - Memory pressure
   - Disk I/O latency
   - Network drops
   - Kubelet health
```


## Summary 
This design provides: 
- A structured observability approach - metrics angle 
- Fast troubleshooting from top-level symptoms -> root cause 
- Properly calculated metrics with PromQL 
- The right visualization types for SRE decision-making 
- A professional, industry-standard dashboard layout 