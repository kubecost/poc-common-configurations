## Prometheus Configs - Federated ETL

Kubecost offers several ways to enable Prometheus for efficient data aggregation and cost monitoring. Below are the available options for configuring Prometheus, depending on your infrastructure needs and existing Prometheus setup:

### 1) **Kubecost Bundled Prometheus (Recommended)**  
The easiest and recommended option is to use the Prometheus instance bundled with Kubecost. This deployment is optimized to minimize interference with other observability systems, containing only the metrics needed for Kubecost. By default, it collects 70-90% fewer metrics than a standard Prometheus setup, making it lightweight and efficient.

While it's possible to disable the bundled Prometheus, Kubecost strongly recommends using it in most environments for optimal performance and integration.

### 2) **Bring Your Own Prometheus**  
For users who already have a Prometheus instance set up in their environment, Kubecost supports custom Prometheus configurations. This option allows you to integrate your existing Prometheus deployment with Kubecost, leveraging your current monitoring stack while adding cost analytics.

### 3) **Other Managed Prometheus Options**  
For users leveraging managed Prometheus services or distributed environments, Kubecost supports integration with the following options:
   - [**Amazon Managed Service for Prometheus (AMP)**](https://docs.kubecost.com/install-and-configure/advanced-configuration/custom-prom/aws-amp-integration)
   - [**AWS Agentless AMP**](https://docs.kubecost.com/install-and-configure/advanced-configuration/custom-prom/kubecost-agentless-amp)
   - [**AWS Distro for OpenTelemetry (ADOT)**](https://docs.kubecost.com/install-and-configure/advanced-configuration/custom-prom/kubecost-aws-distro-open-telemetry)
   - [**AMP with Kubecost Prometheus (`remote_write`)**](https://docs.kubecost.com/install-and-configure/advanced-configuration/custom-prom/amp-with-remote-write)
   - [**Google Cloud Managed Service for Prometheus**](https://docs.kubecost.com/install-and-configure/advanced-configuration/custom-prom/gcp-gmp-integration)
   - [**Grafana Mimir Integration for Kubecost**](https://docs.kubecost.com/install-and-configure/advanced-configuration/custom-prom/grafana-mimir-integration)
   - [**Grafana Cloud Integration for Kubecost**](https://docs.kubecost.com/install-and-configure/advanced-configuration/custom-prom/grafana-cloud-integration)

Each managed Prometheus option has specific configurations and remote write settings to ensure compatibility with Kubecost’s cost analytics and reporting.

### Bundled Prometheus Configuration Files

Kubecost provides two configurations for integrating Prometheus, depending on your use case:

#### **Basic Bundled Prometheus with Recording Rules**  
Use the `bundledprom.yaml` file to set up a basic Prometheus deployment optimized for Kubecost. This setup includes recording rules for cost data aggregation and is lightweight by design, ensuring minimal impact on your existing observability systems.

- **Recording Rules:** Recording rules precompute and store frequently used queries to reduce the load on Prometheus and improve performance. These rules, including CPU and memory utilization ratios, help optimize cost analysis. For more details on Kubecost's recording rules and how to implement them, refer to the official [Kubecost documentation](https://docs.kubecost.com/install-and-configure/advanced-configuration/custom-prom#recording-rules).
  
- **Reducing Query Load:** To further reduce the query load on your Prometheus instance, use preconfigured recording rules. These can be found in the [Kubecost Helm Chart](https://github.com/kubecost/cost-analyzer-helm-chart/blob/v1.106/kubecost.yaml#L398-L413) and include optimizations such as:

```yaml
- record: kubecost:container_cpu_usage_seconds_total:rate5m
  expr: rate(container_cpu_usage_seconds_total[5m])
- record: kubecost:container_memory_usage_bytes
  expr: container_memory_usage_bytes
```

These rules precompute metrics, reducing the overall query load and ensuring smoother performance across the environment.

#### **Prometheus Configurations for the Cost Analyzer Helm Chart**  
If you're using the Kubecost Helm chart and need to adjust Prometheus configurations, including scrape intervals or integrating with managed services, the `costanalyzer-prometheus-configs.yaml` file is available.

- This configuration allows for more granular control, including custom scrape intervals, targets, and remote write settings for managed services like [Amazon Managed Prometheus (AMP)](https://docs.kubecost.com/install-and-configure/advanced-configuration/custom-prom/aws-amp-integration) or [Google Cloud Managed Prometheus (GMP)](https://docs.kubecost.com/install-and-configure/advanced-configuration/custom-prom/gcp-gmp-integration).

### Bring Your Own Prometheus Configuration

For users who already have a Prometheus instance set up in their environment, Kubecost supports custom Prometheus configurations. You can integrate your existing Prometheus deployment with Kubecost by making use of two key files: `byoprometheus.yaml` for the basic setup and `extrascrapeconfigs.yaml` for additional scrape configurations.

#### **Basic BYO Prometheus Setup**  
To get started with integrating Kubecost into your Prometheus instance, refer to the basic configuration in the `byoprometheus.yaml` file. This setup includes the necessary settings to enable Kubecost’s cost aggregation and reporting, while allowing you to maintain your existing observability stack.

#### **Extra Scrape Configurations**  
After setting up your basic Prometheus configuration, you’ll need to embed additional scrape configurations to ensure Kubecost is gathering the necessary data for cost analysis. These scrape configs are located in the `extrascrapeconfigs.yaml` file.

For details on where to add these scrape configs, refer to the [Prometheus documentation on scrape configurations](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config).By embedding these scrape configurations into your existing Prometheus setup, you ensure that Kubecost has access to the necessary metrics for accurate cost reporting.

