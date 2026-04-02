#!/bin/bash
podman pull s3://tusaas-bucket/k8s-collector:latest
podman run -d \
  -e API_KEY=sk_live_XXXX \
  -e API_URL=https://api.tusaas.com/metrics \
  -v ~/.kube/config:/root/.kube/config:Z \
  --name k8s-collector \
  k8s-collector:latest
