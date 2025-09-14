#!/bin/bash

# NASS Analysis Environment Setup - Fixed for Debian 12+
# Fast R package installation + Jupyter Lab setup

set -e  # Exit on any error

# Logging setup
LOG_FILE="/var/log/startup-script.log"
exec > >(tee -a $LOG_FILE)
exec 2>&1

echo "🚀 NASS Analysis Environment Setup Starting..."
echo "================================================"
echo "Timestamp: $(date)"

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
    python3-full \
    pipx \
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

# Install available system packages (fastest)
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
    || echo "⚠️ Some apt R packages not available (continuing...)"

echo "✅ System R packages installed"

# Install remaining R packages from CRAN
echo "📦 Installing additional R packages from CRAN..."
R --slave -e "
options(repos = c(CRAN = 'https://cloud.r-project.org'))
options(Ncpus = $(nproc))

packages_needed <- c('survey', 'IRkernel')
packages_to_install <- packages_needed[!packages_needed %in% rownames(installed.packages())]

if(length(packages_to_install) > 0) {
  for(pkg in packages_to_install) {
    cat('Installing', pkg, '...\n')
    tryCatch({
      install.packages(pkg, type = 'binary', dependencies = FALSE, quiet = TRUE)
      cat('✅', pkg, 'installed\n')
    }, error = function(e) {
      cat('❌', pkg, 'failed\n')
    })
  }
}
"

echo "✅ R packages installation complete"

# =====================================
# PYTHON ENVIRONMENT SETUP (FIXED)
# =====================================

echo "🐍 Setting up Python environment..."

# Create virtual environment to avoid system package conflicts
python3 -m venv /opt/python-env
source /opt/python-env/bin/activate

# Install Python packages in virtual environment
pip install --upgrade pip
pip install \
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
mkdir -p /opt/nass
cd /opt/nass

# Download project files
echo "📥 Downloading NASS analysis files..."
wget -q https://github.com/SeenaKhosravi/NASS/archive/refs/heads/main.zip
unzip -q main.zip
mv NASS-main/* . 2>/dev/null || true
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
# R KERNEL SETUP
# =====================================

echo "🔧 Setting up R kernel for Jupyter..."

source /opt/python-env/bin/activate
R --slave -e "
if('IRkernel' %in% rownames(installed.packages())) {
  IRkernel::installspec(user = FALSE)
  cat('✅ R kernel installed\n')
}
"

# =====================================
# SERVICE SETUP (FIXED PATHS)
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
ExecStart=/opt/python-env/bin/jupyter lab
Restart=always
RestartSec=10
Environment=PATH=/opt/python-env/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

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
sleep 10

# Check service status
if systemctl is-active --quiet jupyter-nass; then
    echo "✅ Jupyter service is running"
    JUPYTER_STATUS="✅ Running"
else
    echo "⚠️ Jupyter service not running, attempting manual start..."
    cd /opt/nass
    source /opt/python-env/bin/activate
    nohup jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token='' > /var/log/jupyter-manual.log 2>&1 &
    sleep 5
    JUPYTER_STATUS="⚠️ Manual start"
fi

# Test connectivity
if curl -s http://localhost:8888 > /dev/null; then
    echo "✅ Jupyter responding on localhost:8888"
else
    echo "⚠️ Jupyter not responding locally"
fi

# Get external IP
EXTERNAL_IP=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)

# =====================================
# COMPLETION MESSAGE
# =====================================

cat << EOF

🎉 NASS Analysis Environment Ready!
================================================

🔗 Access your analysis at:
   http://${EXTERNAL_IP}:8888

📊 Status: ${JUPYTER_STATUS}

Setup completed at: $(date)
Total setup time: $SECONDS seconds

🚀 Happy analyzing!

EOF

echo "🏁 Startup script completed!"