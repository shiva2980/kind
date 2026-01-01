#!/bin/bash

BACKUP_DIR="kind-backup"
MANIFEST_DIR="$BACKUP_DIR/manifests"

echo "🔄 Restoring Kubernetes cluster resources..."

if [ ! -d "$MANIFEST_DIR" ]; then
  echo "❌ Backup folder not found. Please run the backup script first."
  exit 1
fi

echo "⛩️  Restoring Namespaces..."
kubectl apply -f "$MANIFEST_DIR/namespaces.yaml"

echo "📥 Restoring ConfigMaps..."
kubectl apply -f "$MANIFEST_DIR/configmaps.yaml" || echo "⚠️  Failed to restore some ConfigMaps"

echo "🔐 Restoring Secrets..."
kubectl apply -f "$MANIFEST_DIR/secrets.yaml" || echo "⚠️  Failed to restore some Secrets"

echo "💾 Restoring PersistentVolumes and PersistentVolumeClaims..."
kubectl apply -f "$MANIFEST_DIR/pv.yaml"
kubectl apply -f "$MANIFEST_DIR/pvc.yaml"

echo "📦 Restoring all core workloads (Deployments, Services, etc.)..."
kubectl apply -f "$MANIFEST_DIR/cluster-backup.yaml"

echo "📡 Restoring ArgoCD Applications..."
kubectl apply -f "$MANIFEST_DIR/argocd-apps.yaml"

echo "📊 Restoring Helm values for Grafana (if available)..."
if [ -f "$MANIFEST_DIR/grafana-values.yaml" ]; then
  helm upgrade --install grafana grafana/grafana \
    -f "$MANIFEST_DIR/grafana-values.yaml" \
    -n monitoring --create-namespace
fi

echo "📈 Restoring Helm values for Prometheus (if available)..."
if [ -f "$MANIFEST_DIR/prometheus-values.yaml" ]; then
  helm upgrade --install prometheus prometheus-community/prometheus \
    -f "$MANIFEST_DIR/prometheus-values.yaml" \
    -n monitoring --create-namespace
fi

echo "✅ Restore complete. Your cluster should now be back in original state."

# executable permissions
#chmod +x restore-kind-cluster.sh
# to run the script
#./restore-kind-cluster.sh
