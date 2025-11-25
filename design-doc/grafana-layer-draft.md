```
Grafana
├── Folder: Component Metrics
│   ├── Dashboard: Node Health
│   │   ├── Panel: CPU Usage per Node
│   │   ├── Panel: Memory Usage per Node
│   │   ├── Panel: Disk I/O
│   │   ├── Panel: Load Average & Swap Usage
│   │   ├── Panel: Inode Usage
│   │   └── Panel: Network Interface Stats (Throughput, Errors)
│   │
│   ├── Dashboard: Pod & Container Metrics
│   │   ├── Panel: Pod CPU Usage
│   │   ├── Panel: Pod Memory Usage
│   │   ├── Panel: Container Restarts
│   │   ├── Panel: Container Disk Usage
│   │   └── Panel: Container Network Metrics (Latency, Traffic)
│   │
│   ├── Dashboard: Control Plane Components
│   │   ├── Panel: API Server Request Latency
│   │   ├── Panel: API Server Errors
│   │   ├── Panel: Scheduler Queue Length & Bind Latency
│   │   ├── Panel: Controller Manager Reconcile Latency
│   │   └── Panel: etcd Request Latency & Leader Status
│
└── Folder: Layer Metrics
    ├── Dashboard: Workload Layer
    │   ├── Panel: Deployment Status / Replica Health
    │   ├── Panel: Pod Distribution Across Nodes
    │   └── Panel: Workload Resource Utilization (CPU/Memory)
    │
    ├── Dashboard: Networking Layer
    │   ├── Panel: Service Request Rate
    │   ├── Panel: Ingress Controller Latency & Errors
    │   ├── Panel: Network Policy Hit / Deny Stats
    │   └── Panel: Cross-Pod Communication Latency
    │
    ├── Dashboard: Storage Layer
    │   ├── Panel: PV / PVC Usage
    │   ├── Panel: CSI Driver Latency & Errors
    │   └── Panel: IOPS / Throughput per Volume
    │
    └── Dashboard: Application / Middleware Layer
        ├── Panel: API Request Rate & Latency
        ├── Panel: Error Rate
        ├── Panel: Background Jobs / Queue Length
        ├── Panel: Custom Microservice Metrics (e.g., JVM Heap, Go GC)
        └── Panel: Cross-Service Call Graph / Trace Metrics
```