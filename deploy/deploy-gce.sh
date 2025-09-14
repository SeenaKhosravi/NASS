#!/bin/bash
set -e

# NASS Analysis GCE Deployment Script
# Creates a Debian instance with R + Python + Jupyter environment

echo "🚀 NASS Analysis GCE Deployment Starting..."
echo "================================================"

# Configuration
INSTANCE_NAME="nass-analysis"
MACHINE_TYPE=${MACHINE_TYPE:-"n2-highmem-8"}  # 8 vCPUs, 64GB RAM - override with env var
BOOT_DISK_SIZE="50GB"
ZONE=${ZONE:-"us-central1-a"}
# You can override MACHINE_TYPE and ZONE by setting env vars before running the script
# Example: MACHINE_TYPE="n2-standard-4" ZONE="us-west1-b" ./deploy/deploy-gce.sh
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    echo "❌ No project configured!"
    echo "💡 Run: gcloud config set project YOUR_PROJECT_ID"
    echo "💡 Or: gcloud projects list (to see available projects)"
    exit 1
fi

echo "📋 Configuration:"
echo "   Project: $PROJECT_ID"
echo "   Instance: $INSTANCE_NAME"
echo "   Machine: $MACHINE_TYPE"
echo "   Zone: $ZONE"
echo "   Disk: $BOOT_DISK_SIZE"
echo ""

# Check if instance already exists
if gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE &>/dev/null; then
    echo "⚠️  Instance '$INSTANCE_NAME' already exists!"
    echo "   To recreate, first delete it:"
    echo "   gcloud compute instances delete $INSTANCE_NAME --zone=$ZONE"
    exit 1
fi

# Create the instance with startup script
echo "🔨 Creating GCE instance..."

gcloud compute instances create $INSTANCE_NAME \
    --zone=$ZONE \
    --machine-type=$MACHINE_TYPE \
    --boot-disk-size=$BOOT_DISK_SIZE \
    --boot-disk-type=pd-standard \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --tags=jupyter-server,http-server,https-server \
    --metadata-from-file startup-script=deploy/startup-script.sh \
    --scopes=https://www.googleapis.com/auth/cloud-platform

echo "✅ Instance created successfully!"

# Create firewall rule for Jupyter (if it doesn't exist)
if ! gcloud compute firewall-rules describe allow-jupyter &>/dev/null; then
    echo "🔧 Creating firewall rule for Jupyter..."
    gcloud compute firewall-rules create allow-jupyter \
        --allow tcp:8888 \
        --source-ranges 0.0.0.0/0 \
        --target-tags jupyter-server \
        --description "Allow Jupyter Lab access"
    echo "✅ Firewall rule created!"
else
    echo "✅ Firewall rule already exists"
fi

# Wait for instance to be ready
echo "⏳ Waiting for instance to start..."
gcloud compute instances wait-until-ready $INSTANCE_NAME --zone=$ZONE

# Get external IP
EXTERNAL_IP=$(gcloud compute instances describe $INSTANCE_NAME \
    --zone=$ZONE \
    --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

echo ""
echo "🎉 Deployment initiated successfully!"
echo "================================================"
echo "Instance: $INSTANCE_NAME"
echo "External IP: $EXTERNAL_IP"
echo "Zone: $ZONE"
echo ""
echo "⏳ Setup is running in background (2-4 minutes)..."
echo "📝 You can monitor progress with:"
echo "   gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --command='tail -f /var/log/startup-script.log'"
echo ""
echo "🔬 Jupyter will be available at:"
echo "   http://$EXTERNAL_IP:8888"
echo ""
echo "💡 Useful commands:"
echo "   # SSH to instance"
echo "   gcloud compute ssh $INSTANCE_NAME --zone=$ZONE"
echo ""
echo "   # Stop instance (save money)"
echo "   gcloud compute instances stop $INSTANCE_NAME --zone=$ZONE"
echo ""
echo "   # Delete instance"
echo "   gcloud compute instances delete $INSTANCE_NAME --zone=$ZONE"
echo ""
echo "🚀 Happy analyzing!"