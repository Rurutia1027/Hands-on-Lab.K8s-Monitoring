# SRE-Grade Multi-Layer Monitoring Architecture 
A modern Kubernetes/SRE monitoring stack typically includes: 

#### Layer 0 - Infrastructure Layer (HOst / VM / Bare Metal)

#### Layer 1 - Kubernetes Control Plane Layer 
- Data source: Prometheus scraping API server, scheduler, controller-manager, etcd
- FOcus: cluster health, API latencies, availability, workloads health

#### Layer 2 - Kubernetes Workload/Pod Layer 
- Data source: Kube-State-Metrics (KSM) + cAdvisor 
- Focus: pod lifecycle, restarts, resource requests/limits, throttling. 

#### Layer 3 - Service Layer 
- Data Source: Service metrics + Ingress/Nginx/Envoy
- Focus: request rates, latencies, errors


#### Layer 4 - Application Layer 
- Data source: App metrics (OpenTelementry, custom metrics)
- Focus: SLO metrics (APIs, endpoints)


#### Layer 5 - Business Layer 
- Data source: app-level counters
- Focus: Order rate, checkout, success rate, etc. 

---

## Node Exporter (Host Metrics)
### CPU
**Metric-1**
- Metric Name: `node_cpu_seconds_total{mode!="idle"}
- Metric Meaning: Non-idle CPU time
- Formular/Notes: CPU usage = 1 - rate(node_cpu_seconds_total{mode="idle"}[5m])

**Metric-2**
- Metric Name: `node_load1, node_load5, node_load15`
- Meaning: Loading averages
- Formular/Notes: Compare with CPU cores 


### Memory
**Metric-1**
- Metric Name: `node_memory_MemTotal_bytes`
- Meaning: Total memory 

**Metric-2**
- Metric Name: `node_memory_MemAvailable_bytes`
- Meaning: Available memory
- Formular/ Notes: Memory usage =  1 - (MemAvailable / MemTotal)

**Metric-3**
- Metric Name: `node_vmstat_pgmajfault`
- Meaning: Major page faults
- Formular: High -> memory pressure 

### Disk 
**Metric-1**
- Metric Name: `node_filesystem_avail_bytes`
- Meaning: Available disk space 
- Formula: Disk usage = 1  - (avail/size)

**Metric-2**
- Metric Name: `node_disk_io_time_seconds_total`
- Meaning: IO busy time
- Formula: IO util = rate(io_time_seconds_total[5m])


### Network 
**Metric-1**
- Metric Name: `node_network_receive_bytes_total`
- Meaning: RX bytes 

**Metric-2**
- Metric Name: `node_network_transmit_bytes_total`
- Meaning: TX bytes 

**Metric-3**
- Metric Name: `node_network_receive_drop_total`
- Meaning: Dropped packets 

## cAdvisor Metrics (Pod & Container Resource Usage)
### CPU 
**Metric-1**
- Metric Name : `container_cpu_usage_seconds_total`
- Meaning: Total CPU Time 
- Formular: CPU usage = rate(container_cpu_usage_seconds_total{image!=""}[2m])

**Metric-2**
- Metric Name: `container_cpu_cfs_throttled_seconds_total`
- Meaning: Throttling
- Formular: Throttling % = rate(throttled/period)

### Memory
**Metric-1**
- Metric Name: `container_memory_usage_bytes`
- Meaning: Current memory usage 

**Metric-2**
- Metric Name: `container_memory_working_set_bytes`
- Meaning: Real working set (exclue cache)

**Metric-3**
- Metric Name: `container_memory_rss`
- Meaning: RSS


### Disk 
- Meatric Name: `container_fs_reads_bytes_total`
- Metric Name: `container_fs_writes_bytes_total`
 