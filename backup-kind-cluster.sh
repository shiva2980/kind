#!/bin/bash

BACKUP_DIR="kind-backup"
MANIFEST_DIR="$BACKUP_DIR/manifests"
VOLUME_DIR="$BACKUP_DIR/volumes"

echo "📦 Creating backup folders..."
mkdir -p "$MANIFEST_DIR"
mkdir -p "$VOLUME_DIR"

echo "📂 Backing up all K8s resources (Deployments, Services, DaemonSets, StatefulSets, etc.)..."
kubectl get all --all-namespaces -o yaml > "$MANIFEST_DIR/cluster-backup.yaml"

echo "📂 Backing up namespaces..."
kubectl get ns -o yaml > "$MANIFEST_DIR/namespaces.yaml"

echo "📂 Backing up ArgoCD applications..."
kubectl get applications.argoproj.io -n argocd -o yaml > "$MANIFEST_DIR/argocd-apps.yaml"

echo "📂 Backing up PersistentVolumeClaims and PersistentVolumes..."
kubectl get pvc --all-namespaces -o yaml > "$MANIFEST_DIR/pvc.yaml"
kubectl get pv -o yaml > "$MANIFEST_DIR/pv.yaml"

echo "📂 Backing up ConfigMaps and Secrets..."
kubectl get configmaps --all-namespaces -o yaml > "$MANIFEST_DIR/configmaps.yaml"
kubectl get secrets --all-namespaces -o yaml > "$MANIFEST_DIR/secrets.yaml"

echo "📂 Backing up Helm values (Grafana and Prometheus)..."
helm get values grafana -n monitoring -o yaml > "$MANIFEST_DIR/grafana-values.yaml" 2>/dev/null || echo "⚠️  Grafana not found"
helm get values prometheus -n monitoring -o yaml > "$MANIFEST_DIR/prometheus-values.yaml" 2>/dev/null || echo "⚠️  Prometheus not found"

echo "✅ Backup complete. All files stored in: $BACKUP_DIR"

# Example: copy volume data from control-plane node
#docker cp dev-kind-cluster-control-plane:/mnt/data $VOLUME_DIR/control-plane-data

# make it executable
#chmod +x backup-kind-cluster.sh
