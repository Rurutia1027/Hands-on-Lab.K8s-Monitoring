# Top 5 High-Frequency Grafana Visualizations
## Time Series (Most Common)
### Purpose: Trend analysis, spikes, patterns, anomalies over time
- Panel Name: Container CPU Usage (Time Series)
- Metric Example: `rate(container_cpu_usage_seconds_total{name=~".*"}[5m]) * 1000`
- Unit: millicores
- Explanation: CPU consumption trend of containers; shows spikes and load patterns. 

## Gauge (Real-Time Status)
### Purpose: Current resource usage at a glance; good for SLIs.
- Panel Name: Container Memory Working Set (Gauge)
- Metric Example: `container_memory_working_set_bytes{name=~".*"} / 1024 / 1024`
- Unit: MB 
- Explanation: Current working set memory per container or node. 

## Stat Panel (Single Value Insight)
### Purpose: Show a single key number such as total pods, node count, high CPU container etc. 
- Panel Name: Total Pods (Stat)
- Metric Example: `sum(kube_pod_info)`
- Unit Count: Count
- Explanation: Shows the total number of Pods running. 

## Bar Gauge (Ranked Comparative View)
### Purpose: Top N usage visualization, easy to see which container/node is highest.
- Panel Name: Top 5 Containers by Memory Usage (Bar Gauge)
- Metric Exampe: `topk(5, container_memory_working_set_bytes{name=~".*"}) / 1024 / 1024`
- Unit: MB
- Explanation: Shows top 5 containers consuming the most memory.

## Table Panel (Detailed Multi-Dimension Metrics)
### Purpose: Used when many labels and fields must be shown to the user. 
- Panel Name: Container Network Transmit (Table)
- Metric Example: `rate(container_network_transmit_bytes_total[5m]) / 1024`
- Unit: KB/s
- Explanation: Per-container network TX with labels: pod name, container name, namespace, etc. 
