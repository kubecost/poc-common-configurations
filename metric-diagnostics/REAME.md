# Kubecost Metrics Diagnostics

This script is designed to be used for support purposes when troubleshooting Kubecost metrics. It can be used to determine if any metrics are missing from the local Prometheus instance.

## Diagnostics pod

See:

[Pod manifest](kubecost-metric-check.yaml) which runs this script: [kubecost-prometheus-healthcheck.sh](kubecost-prometheus-healthcheck.sh)

The image can be built with the following command, or use the latest provided image.

```sh
docker build --push -t YOUR_REGISTRY/kubecost-metric-check .
```

