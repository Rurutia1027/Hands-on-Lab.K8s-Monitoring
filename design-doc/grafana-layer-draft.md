# Grafana Monitoring Architecture Design Doc 
_Version: 1.0_
_Scope: Kubernetes Cluster Observability Design_

## Overview 
This document describes the logical and structural design for the Grafana monitoring environment for the Kubernetes cluster. The goal is to provide: 
- A **component-centric view** (control plane, system services, infrastructure components)
- A **layer-centric view** (node -> pod -> container -> service -> ingress -> storage).

The architecture uses **two top-level Grafana folders**, each containing multiple dashboards with consistent naming, layout, and PromQL patterns. 

The finalized design ensures the monitoring experience follows SRE observability standards, supports troubleshooting workflows, and simplifiest the navigation for day-to-day operations. 

## High-Level Objectives 
#### Establish a clear separation between 
- Component monitoring 
- Layer/function monitoring 

#### Ensure dashboards are grouped intuitively so SREs can quickly locate: 
- System-wide issues
- Component failures 
- Layer performance bottlenecks

#### Standarize all dashboards with: 
- Consistent naming 
- Consistent panel grouping 
- Consistent color and layout 
- Standard PromQL patterns and labels

#### Support incremental expansion as more metrics sources (KSM, kubelet, runtime, CNI, etc.) are onboarded. 

## Folder Structure 
Grafana will contain two top-level folders, each representing a distinct conceptual view of the cluster. 

### Folder A: Kubernetes -- Component View 
**Purpose**
Monitor the health, performance, and behavior of **individual components** of the Kubernetes control plane and node infrastructure. 

Dashboards in this folder will describe what each component is doing. 

Expected dashboards: 
- API Server - Performance 
- Scheduler - Scheduling Latency 
- Controller Manager - Workqueue Metrics 
- etcd - Storage Performance 
- Kubelet - Node Interface 
- Container Runtime - containerd
- CoreDNS - DNS Resolution 
- CNI / Network Plugin - Traffic & Errors 


### Folder B: Kubernetes -- Layer View 
**Purpose**
Provide the end-to-end operational view across **logical layers** of the cluster. 

Dashboards here describe how workloads behave across layers. 

Expected dashboards: 
- Node Layer - Node Health 
- Pod Layer - Workload State 
- Container Layer - Resource Usage 
- Service Layer - Service Traffic 
- Ingress Layer - External Access 
- Storage Layer - Volume & IO
- Control Plane Layer - Cluster Summary 

## Dashboard Skeleton Templates 
Each dashboard follows a **three-zone** structure. 

### Dashboard Structural Skeleton 
```
Dashboard
 ├── Header Section
 │     • Summary KPIs (Stat Panels)
 │     • Up/Down indicators
 │     • Health score (optional)
 │
 ├── Row Group 1: Overview
 │     • High-level performance charts
 │     • Resource usage
 │     • Request rates or workload counts
 │
 ├── Row Group 2: Detailed Metrics
 │     • Deep dive metrics (latency, IO, cache, errors)
 │     • Histograms
 │     • Rates and cumulative counters
 │
 └── Row Group 3: Alerts & Diagnostic View
       • Critical conditions
       • Saturation signals
       • Error counts
```
This structure stays consistent across all dashboards. 

## Dashboard Skeleton for Each Folder 
### Component View - Dashboard Skeletons 
_take API Server for example_

- We need to figure out the components across the cluster: who talks to API Server, as Client or as Server ? 

```
Header KPIs: 
- apiserver_request_total 
- request latency P50/P90/P99
- inflight_request count 
- 5xx error rate 

Row: Request Latency Breakdown 
- request_duration_seconds_bucket by verb 
- histogram quantile panels 

Row: Request Volume & Errors 
- request_total by verb 
- request_total by resource
- error response (4xx / 5xx)

Row: Watcher & etcd Interaction 
- watch events sent 
- etcd request latency

Row: Alerts
- high API latency 
- high error percentage
```

_take Scheduler - Scheduling Latency as example here_

```
Header KPIs
- scheduler_e2e_scheduling_latency_seconds P99
- scheduling throughput 

Row: Scheduling Workflow 
- scheduling latency histogram 
- scheduling attempts 

Row: Queues
- priority queue length 
- scheduling failures 

Row: Alerts 
...
```


## Layer View - Dashboard Skeletones 

### Node Layer - Node Health 
```
Header KPIs
- node_up
- CPU total used %
- Memory used %
- Disk root filesystem used % 

Row: CPU & Load 
- node_load1/5/15
- CPU user/system/iowait 

Row: Memory Behavior 
- memory working set 
- page cache 
- swap usage 

Row: Filesystem & IO
- disk usage
- IO wait 
- IOPS / latencies 

Row: Network 
- rx/tx throughput 
- packet drops 

Row: Alerts 
```

### Pod Layer - Workload State 
```
Header KPIs:
- Total pods 
- Running / Failed / Pending 
- Pod restarts 

Row: Pod Resource Usage 
Row: Pod Restarts 
Row: Pod Life Cycle Events 
Row: Alerts 
...
```


### Container Layer - Runtiem Metrics 
```
Header KPIs: 
- container CPU used %
- throttling % 
- memory working set 

Rows: 
- CPU Throttling 
- Memory Limits vs Usage 
- OOM events 
- Alerts 
```


<!-- ## Folder xxx -> from the namespace xxx  -->


## Naming Conventions 
### Folders 
```
k8s-components
k8s-layers
```

### Dashboars 
```
{Layer/Component} - {Domain}
```

```
Node Layer - Node Health 
Pod Layer - Workload Status 
API Server - Performance 
etcd - Storage Latency 
CoreDNS - Query Resolution
```

### Panels 
{metric description} - {dimension}

```
CPU Usage (%) - Node 
Memory Working Set - Container 
Request Latency P99 - API Server 
Disk IO - Node 
```

## Metrics Sources (Data Ingestion Overview)

#### Node Exporter 
- Targets Provided: Node OS metrics 
- Dashbaords Using It: Node Layer, Component deep dive

#### Kube-State-Metrics 
- Target Provider: Pod/Deploy/StatefulSet/Servie status
- Dashboards Using It: Container Layer 


#### API Server Metrics
- Target Provider: Latency, errors
- Dashboards Using It: API Server Dashboard 

#### Scheduler 
- Target Provider: Scheduling performance
- Dashboards: Scheduler dashboard 

#### Controller Manager 
- Target Provider: Scheduling performance
- Dashboards: Scheduler dashboard 


#### etcd
- Target Provider: Queue metrics
- Dashboards: CM dashboards 


#### cAdvisor 
- Target Provider: Container metrics
- Dashboards Using it: Container Layer 

#### CoreDNS 
- Target Provider: DNS resolution 
- Dashboards Using it: DNS dashboard 

## Future Extension 
- Add Multi-Cluster View dashboards 
- Integrate Loki for logs in-component view
- Add Tempo for tracing 
- **Build Grafana "Drilldown Links" between Components -> Layer -> Instance** - this seems interesting and useful.


## Conclusion 
This design defines a clear and maintainable structure for Grafana dashboards convering both Kubernentes and Kubernentes funcitonal layers. 
The folder separation ensures SRE can quickly locate the correct dashboards on whether they are debugging components or workloads.