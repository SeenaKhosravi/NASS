#!/bin/bash
set -e

# NASS Analysis GCE Deployment Script
# Creates a Debian instance with R + Python + Jupyter environment

echo "🚀 NASS Analysis GCE Deployment Starting..."
echo "================================================"

# Configuration
INSTANCE_NAME="nass-analysis"
MACHINE_TYPE=${MACHINE_TYPE:-"n2-highmem-8"}  # 8 vCPUs, 64GB RAM - override with env var
BOOT_DISK_SIZE=${BOOT_DISK_SIZE:-"100GB"}  # 100GB boot disk
ZONE=${ZONE:-"us-central1-a"}
# You can override MACHINE_TYPE, BOOT_DISK_SIZE, and ZONE by setting env vars before running the script
# Example: MACHINE_TYPE="n2-standard-4" ZONE="us-west1-b" BOOT_DISK_SIZE="200GB" ./deploy/deploy-gce.sh

# Better project detection and setup
echo "🔧 Configuring project..."

# Try to get current project
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

# If no project set, try to auto-detect
if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" = "(unset)" ]; then
    echo "⚠️  No project currently set, auto-detecting..."
    
    # Get the first available project
    PROJECT_ID=$(gcloud projects list --format="value(projectId)" --limit=1 2>/dev/null)
    
    if [ -z "$PROJECT_ID" ]; then
        echo "❌ No projects found!"
        echo "💡 Please create a project first at: https://console.cloud.google.com/projectcreate"
        exit 1
    fi
    
    echo "📋 Found project: $PROJECT_ID"
    echo "� Setting as default project..."
    gcloud config set project "$PROJECT_ID"
    
    if [ $? -eq 0 ]; then
        echo "✅ Project configured successfully"
    else
        echo "❌ Failed to set project"
        exit 1
    fi
else
    echo "✅ Using existing project: $PROJECT_ID"
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

# Wait for instance to be ready and responsive
echo "⏳ Waiting for instance to start and become ready..."
for i in {1..12}; do
    if gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE --format="value(status)" | grep -q "RUNNING"; then
        echo "✅ Instance is running"
        break
    fi
    echo "   Attempt $i/12: Still starting..."
    sleep 10
done

# Additional wait for SSH to be ready
echo "⏳ Waiting for SSH access..."
for i in {1..6}; do
    if gcloud compute ssh $INSTANCE_NAME --zone=$ZONE --command="echo 'SSH ready'" --quiet 2>/dev/null; then
        echo "✅ SSH is ready"
        break
    fi
    echo "   SSH attempt $i/6: Not ready yet..."
    sleep 10
done

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