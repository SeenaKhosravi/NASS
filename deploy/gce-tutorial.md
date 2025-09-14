# Deploy NASS Analysis on Google Compute Engine

**Welcome!** This tutorial will deploy your NASS Analysis environment in ~3 minutes.

<walkthrough-author name="NASS Team" repositoryUrl="https://github.com/SeenaKhosravi/NASS" tutorialName="gce-tutorial"></walkthrough-author>

## Introduction

<walkthrough-tutorial-duration duration="5"></walkthrough-tutorial-duration>

You will:
- Create a GCE instance with R + Python + Jupyter
- Download the NASS analysis notebook
- Access a ready-to-use analysis environment

Click **Start** to begin!

## Step 1: Verify Your Project

Let's confirm your Google Cloud project is set up correctly.

<walkthrough-project-setup></walkthrough-project-setup>

Your current project: <walkthrough-project-id/>

If this isn't correct, click the project selector above.

## Step 2: Enable Required APIs

<walkthrough-enable-apis apis="compute.googleapis.com"></walkthrough-enable-apis>

The Compute Engine API is now enabled for your project.

## Step 2.5: Configure Project

Let's ensure your project is properly configured:

```bash
# Auto-detect and set your project
PROJECT_ID=$(gcloud config get-value project 2>/dev/null || gcloud projects list --limit=1 --format="value(projectId)")
gcloud config set project $PROJECT_ID
echo "Using project: $PROJECT_ID"
```

<walkthrough-copy-code-button></walkthrough-copy-code-button>

This ensures the deployment script can access your project.

## Step 3: Set Your Preferred Zone

Choose a zone close to your location for better performance:

```bash
export ZONE="us-central1-a"
echo "Using zone: $ZONE"
```

<walkthrough-copy-code-button></walkthrough-copy-code-button>

**Other options:** `us-east1-a`, `europe-west1-a`, `asia-southeast1-a`

## Step 4: Deploy Your Instance

Now let's create your NASS analysis environment:

```bash
chmod +x deploy/deploy-gce.sh
./deploy/deploy-gce.sh
```

<walkthrough-copy-code-button></walkthrough-copy-code-button>

This script will:
- ✅ Create a Debian instance
- ✅ Install R, Python, Jupyter
- ✅ Download NASS notebook
- ✅ Start Jupyter Lab

**⏳ This takes 2-4 minutes** - watch the terminal for progress!

## Step 5: Get Your Jupyter URL

Once deployment completes, get your instance's external IP:

```bash
gcloud compute instances describe nass-analysis \
    --zone=$ZONE \
    --format='value(networkInterfaces[0].accessConfigs[0].natIP)'
```

<walkthrough-copy-code-button></walkthrough-copy-code-button>

Your Jupyter Lab will be at: `http://[EXTERNAL-IP]:8888`

## Step 6: Open Your Analysis

Click the Jupyter URL from the previous step, then:

1. **Navigate** to `Analysis_NASS.ipynb`
2. **Click** to open the notebook
3. **Start analyzing!** - All dependencies are pre-installed

## What's Next?

Your NASS analysis environment is ready! Here are some useful commands:

### Monitor Your Instance
```bash
# Check if Jupyter is running
gcloud compute ssh nass-analysis --zone=$ZONE --command='systemctl status jupyter-nass'

# View setup logs
gcloud compute ssh nass-analysis --zone=$ZONE --command='tail -f /var/log/startup-script.log'
```

### Manage Costs
```bash
# Stop instance when not in use
gcloud compute instances stop nass-analysis --zone=$ZONE

# Start instance
gcloud compute instances start nass-analysis --zone=$ZONE

# Delete instance (WARNING: destroys all data)
gcloud compute instances delete nass-analysis --zone=$ZONE
```

## Troubleshooting

**Can't access Jupyter?**
- Wait 2-3 minutes for full setup
- Check firewall: `gcloud compute firewall-rules list --filter="name:allow-jupyter"`
- Verify instance is running: `gcloud compute instances list`

**Need help?**
- 📖 [Full documentation](https://github.com/SeenaKhosravi/NASS)
- 🐛 [Report issues](https://github.com/SeenaKhosravi/NASS/issues)

## Conclusion

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

🎉 **Success!** Your NASS analysis environment is deployed and ready.

**Next Steps:**
1. Open Jupyter at your instance IP
2. Run the Analysis_NASS.ipynb notebook
3. Explore socioeconomic patterns in ambulatory surgery data

**Remember to stop** your instance when done to save costs!

<walkthrough-inline-feedback></walkthrough-inline-feedback>

**Note:** First-time users will be prompted to generate SSH keys. This is normal and secure - just press Enter twice when prompted.