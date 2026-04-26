# ☸️ k8s-manifests

> Production-ready Kubernetes manifests — Deployments, Services, ConfigMaps, Ingress, HPA — with Kustomize overlays for dev/prod and a Helm chart.

![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat-square&logo=kubernetes&logoColor=white)
![Helm](https://img.shields.io/badge/Helm-0F1689?style=flat-square&logo=helm&logoColor=white)
![Kustomize](https://img.shields.io/badge/Kustomize-326CE5?style=flat-square&logo=kubernetes&logoColor=white)
![CI](https://github.com/hugpaim/k8s-manifests/actions/workflows/ci.yml/badge.svg)

---

## 📁 Structure

```
k8s-manifests/
├── base/                        # Base Kustomize configs (shared)
│   ├── namespace/               # Namespace definition
│   ├── app/                     # Deployment + Service + HPA
│   ├── configmap/               # App configuration
│   └── ingress/                 # Ingress rules
├── overlays/
│   ├── dev/                     # Dev overrides: 1 replica, debug
│   └── prod/                    # Prod overrides: 3 replicas, resources
├── helm/
│   └── devops-app/              # Helm chart for the same app
└── scripts/
    ├── apply.sh                 # Deploy overlay with kubectl
    └── rollout-status.sh        # Watch rollout progress
```

## 🚀 Quick Start

### With Kustomize
```bash
# Deploy dev overlay
kubectl apply -k overlays/dev

# Deploy prod overlay
kubectl apply -k overlays/prod

# Check resources
kubectl get all -n devops-dev
```

### With Helm
```bash
cd helm/devops-app
helm install devops-app . --namespace devops-dev --create-namespace
helm upgrade devops-app . --namespace devops-dev
```

## 🌍 Environments

| Overlay | Replicas | Resources | Image tag |
|---------|----------|-----------|-----------|
| `dev`   | 1        | minimal   | `latest`  |
| `prod`  | 3        | defined   | pinned SHA |

## ⚙️ Requirements

- kubectl >= 1.28
- Kubernetes >= 1.28 (or [minikube](https://minikube.sigs.k8s.io/) locally)
- Helm >= 3.14 (for Helm chart)

---

> Part of [@hugpaim](https://github.com/hugpaim) DevOps portfolio
