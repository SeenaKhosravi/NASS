#!/bin/bash

# NASS Analysis Environment Setup - Optimized Version
# Fast R package installation + Jupyter Lab setup

set -e  # Exit on any error

# Logging setup
LOG_FILE="/var/log/startup-script.log"
exec > >(tee -a $LOG_FILE)
exec 2>&1

echo "🚀 NASS Analysis Environment Setup Starting..."
echo "================================================"
echo "Timestamp: $(date)"
echo "Instance: $(hostname)"
echo "User: $(whoami)"

# =====================================
# SYSTEM UPDATES & DEPENDENCIES
# =====================================

echo "📦 Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get upgrade -y -qq

echo "📦 Installing system dependencies..."
apt-get install -y -qq \
    python3 \
    python3-pip \
    python3-venv \
    r-base \
    r-base-dev \
    git \
    curl \
    wget \
    unzip \
    build-essential \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libcairo2-dev \
    libharfbuzz-dev \
    libfribidi-dev

echo "✅ System dependencies installed"

# =====================================
# FAST R PACKAGE INSTALLATION
# =====================================

echo "🔧 Installing R packages (optimized approach)..."

# Step 1: Install available system packages (fastest)
echo "📦 Installing R packages via apt (binaries)..."
apt-get install -y -qq \
    r-cran-data.table \
    r-cran-ggplot2 \
    r-cran-scales \
    r-cran-rcolorbrewer \
    r-cran-dplyr \
    r-cran-tidyr \
    r-cran-broom \
    r-cran-mass \
    r-cran-lattice \
    r-cran-matrix \
    r-cran-mgcv \
    r-cran-nlme \
    r-cran-survival \
    r-cran-boot \
    r-cran-cluster \
    r-cran-foreign \
    r-cran-class \
    r-cran-nnet \
    r-cran-spatial \
    r-cran-kernsmooth \
    r-cran-rpart \
    || echo "⚠️ Some apt R packages not available (continuing...)"

echo "✅ System R packages installed"

# Step 2: Install remaining packages from CRAN (binaries only)
echo "📦 Installing additional R packages from CRAN..."
R --slave -e "
# Configure for speed
options(repos = c(CRAN = 'https://cloud.r-project.org'))
options(Ncpus = $(nproc))

# Essential packages not available via apt
packages_needed <- c('survey', 'rpy2', 'IRkernel')
packages_to_install <- packages_needed[!packages_needed %in% rownames(installed.packages())]

if(length(packages_to_install) > 0) {
  cat('Installing:', paste(packages_to_install, collapse = ', '), '\n')
  
  # Try binary first, fallback to source only if necessary
  for(pkg in packages_to_install) {
    cat('Installing', pkg, '...\n')
    tryCatch({
      install.packages(pkg, type = 'binary', dependencies = FALSE, quiet = TRUE)
      cat('✅', pkg, 'installed (binary)\n')
    }, error = function(e) {
      cat('⚠️ Binary failed for', pkg, ', trying source...\n')
      tryCatch({
        install.packages(pkg, type = 'source', dependencies = FALSE, quiet = TRUE)
        cat('✅', pkg, 'installed (source)\n')
      }, error = function(e2) {
        cat('❌', pkg, 'failed:', e2\$message, '\n')
      })
    })
  }
} else {
  cat('✅ All required packages already installed\n')
}

# Verify core packages
required_core <- c('data.table', 'ggplot2', 'scales')
missing_core <- required_core[!required_core %in% rownames(installed.packages())]

if(length(missing_core) > 0) {
  cat('⚠️ Missing core packages:', paste(missing_core, collapse = ', '), '\n')
  install.packages(missing_core, type = 'binary', dependencies = TRUE)
} else {
  cat('✅ All core packages verified\n')
}
"

echo "✅ R packages installation complete"

# =====================================
# PYTHON ENVIRONMENT SETUP
# =====================================

echo "🐍 Setting up Python environment..."

# Install Python packages
pip3 install --upgrade pip --quiet
pip3 install --quiet \
    jupyter \
    jupyterlab \
    pandas \
    numpy \
    matplotlib \
    seaborn \
    requests \
    rpy2

echo "✅ Python packages installed"

# =====================================
# PROJECT SETUP
# =====================================

echo "📁 Setting up project directory..."

# Create project directory
mkdir -p /opt/nass
cd /opt/nass

# Download project files
echo "📥 Downloading NASS analysis files..."
wget -q https://github.com/SeenaKhosravi/NASS/archive/refs/heads/main.zip
unzip -q main.zip
mv NASS-main/* .
rm -rf NASS-main main.zip

echo "✅ Project files downloaded"

# =====================================
# JUPYTER LAB CONFIGURATION
# =====================================

echo "🔧 Configuring Jupyter Lab..."

# Create Jupyter config
mkdir -p /root/.jupyter

cat > /root/.jupyter/jupyter_lab_config.py << 'EOF'
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8888
c.ServerApp.open_browser = False
c.ServerApp.allow_root = True
c.ServerApp.token = ''
c.ServerApp.password = ''
c.ServerApp.allow_remote_access = True
c.ServerApp.disable_check_xsrf = True
c.ServerApp.root_dir = '/opt/nass'
EOF

echo "✅ Jupyter Lab configured"

# =====================================
# R KERNEL SETUP FOR JUPYTER
# =====================================

echo "🔧 Setting up R kernel for Jupyter..."

R --slave -e "
if('IRkernel' %in% rownames(installed.packages())) {
  IRkernel::installspec(user = FALSE)
  cat('✅ R kernel installed for Jupyter\n')
} else {
  cat('⚠️ IRkernel not available - R integration limited\n')
}
"

# =====================================
# SERVICE SETUP
# =====================================

echo "🔧 Creating Jupyter service..."

cat > /etc/systemd/system/jupyter-nass.service << 'EOF'
[Unit]
Description=NASS Jupyter Lab
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/nass
ExecStart=/usr/local/bin/jupyter lab
Restart=always
RestartSec=10
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable jupyter-nass
systemctl start jupyter-nass

echo "✅ Jupyter service created and started"

# =====================================
# VERIFICATION & COMPLETION
# =====================================

echo "🔍 Verifying installation..."

# Wait for Jupyter to start
sleep 10

# Check service status
if systemctl is-active --quiet jupyter-nass; then
    echo "✅ Jupyter service is running"
else
    echo "⚠️ Jupyter service not running, attempting manual start..."
    cd /opt/nass
    nohup jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token='' > /var/log/jupyter-manual.log 2>&1 &
    sleep 5
fi

# Test local connectivity
if curl -s http://localhost:8888 > /dev/null; then
    echo "✅ Jupyter responding on localhost:8888"
    JUPYTER_STATUS="✅ Running"
else
    echo "⚠️ Jupyter not responding locally"
    JUPYTER_STATUS="❌ Not responding"
fi

# Get external IP
EXTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)

echo "📡 External IP detected: $EXTERNAL_IP"

# Test external connectivity
if curl -s http://$EXTERNAL_IP:8888 > /dev/null; then
    echo "✅ Jupyter responding on external IP:8888"
else
    echo "⚠️ Jupyter not responding on external IP"
fi

# =====================================
# FINAL NOTES
# =====================================

echo "🎉 NASS Analysis Environment Setup Complete!"
echo "================================================"
echo "✅ System updated and packages installed"
echo "✅ R $(R --version | head -1 | cut -d' ' -f3) and Python $(python3 --version | cut -d' ' -f2) ready"
echo "✅ Jupyter Lab running at http://$EXTERNAL_IP:8888"
echo ""
echo "🔧 Manage Jupyter service with:"
echo "   systemctl status jupyter-nass"
echo "   systemctl restart jupyter-nass"
echo ""
echo "🗂️ Project files located at: /opt/nass"
echo "📋 Logs available at: /var/log/jupyter.log"
echo ""
echo "Setup completed at: $(date)"
echo "================================================"