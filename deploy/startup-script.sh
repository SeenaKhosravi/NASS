#!/bin/bash

# NASS Analysis Debian Setup Script
# Installs R, Python, Jupyter and configures the analysis environment

LOG_FILE="/var/log/startup-script.log"
exec > >(tee -a $LOG_FILE)
exec 2>&1

echo "=========================================="
echo "NASS Analysis Environment Setup Starting"
echo "Time: $(date)"
echo "=========================================="

# Update system
echo "📦 Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get upgrade -y -qq

# Install essential system packages
echo "📦 Installing system dependencies..."
apt-get install -y -qq \
    curl wget git unzip htop tree vim \
    build-essential gfortran \
    python3 python3-pip python3-venv python3-dev \
    r-base r-base-dev r-recommended \
    libssl-dev libcurl4-openssl-dev libxml2-dev \
    libfontconfig1-dev libcairo2-dev libharfbuzz-dev \
    libfribidi-dev libfreetype6-dev libpng-dev \
    libtiff5-dev libjpeg-dev libgit2-dev \
    libgsl-dev libfftw3-dev libudunits2-dev \
    libgdal-dev libproj-dev libgeos-dev

echo "✅ System packages installed"

# Install Python packages
echo "🐍 Installing Python packages..."
pip3 install --no-cache-dir \
    jupyter jupyterlab \
    pandas numpy matplotlib seaborn \
    scipy scikit-learn \
    rpy2 \
    requests psutil

echo "✅ Python packages installed"

# Install R packages
echo "📊 Installing R packages..."
R --slave << 'EOF'
# Set CRAN mirror and use multiple cores
options(repos = c(CRAN = "https://cloud.r-project.org/"))
Sys.setenv(MAKEFLAGS = paste0("-j", parallel::detectCores()))

# Essential packages
essential_packages <- c(
    "data.table", "ggplot2", "scales", "dplyr", "tidyr",
    "survey", "broom", "RColorBrewer", "gtsummary"
)

# Install packages with error handling
for(pkg in essential_packages) {
    cat("Installing", pkg, "...\n")
    tryCatch({
        install.packages(pkg, dependencies = TRUE, quiet = TRUE)
        cat("✅", pkg, "installed\n")
    }, error = function(e) {
        cat("❌", pkg, "failed:", e$message, "\n")
    })
}

# Install IRkernel for Jupyter
if(!require("IRkernel", quietly = TRUE)) {
    install.packages("IRkernel", quiet = TRUE)
}

# Install R kernel
IRkernel::installspec(user = FALSE)
cat("✅ R kernel installed for Jupyter\n")
EOF

echo "✅ R packages installed"

# Configure Jupyter
echo "🔬 Configuring Jupyter..."
mkdir -p /opt/jupyter
cat > /opt/jupyter/jupyter_config.py << 'EOF'
# Jupyter configuration for NASS Analysis
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8888
c.ServerApp.open_browser = False
c.ServerApp.allow_root = True
c.ServerApp.token = ''
c.ServerApp.password = ''
c.ServerApp.notebook_dir = '/opt/nass'
c.ServerApp.allow_origin = '*'
c.ServerApp.disable_check_xsrf = True

# Performance settings
c.ServerApp.max_buffer_size = 268435456  # 256MB
c.ServerApp.iopub_data_rate_limit = 1000000000  # 1GB/s

# Kernel settings
c.MappingKernelManager.default_kernel_name = 'python3'

# File settings
c.ContentsManager.allow_hidden = True
c.FileContentsManager.delete_to_trash = False

# Logging
c.Application.log_level = 'INFO'
EOF

# Create NASS workspace
echo "📁 Setting up NASS workspace..."
mkdir -p /opt/nass
cd /opt/nass

# Download the notebook
echo "📥 Downloading NASS Analysis notebook..."
wget -q https://raw.githubusercontent.com/SeenaKhosravi/NASS/main/Analysis_NASS.ipynb \
    -O Analysis_NASS.ipynb

# Create data directory
mkdir -p data

# Create startup script
cat > /opt/nass/start_jupyter.sh << 'EOF'
#!/bin/bash
cd /opt/nass
export PYTHONPATH=/opt/nass:$PYTHONPATH
jupyter lab --config=/opt/jupyter/jupyter_config.py > /var/log/jupyter.log 2>&1 &
echo $! > /var/run/jupyter.pid
echo "Jupyter started with PID $(cat /var/run/jupyter.pid)"
echo "Access at: http://$(curl -s ifconfig.me):8888"
EOF

chmod +x /opt/nass/start_jupyter.sh

# Create systemd service for Jupyter
cat > /etc/systemd/system/jupyter-nass.service << 'EOF'
[Unit]
Description=Jupyter Lab for NASS Analysis
After=network.target

[Service]
Type=forking
User=root
WorkingDirectory=/opt/nass
ExecStart=/opt/nass/start_jupyter.sh
ExecStop=/bin/kill -TERM $MAINPID
PIDFile=/var/run/jupyter.pid
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Start Jupyter service
echo "🚀 Starting Jupyter service..."
systemctl daemon-reload
systemctl enable jupyter-nass
systemctl start jupyter-nass

# Wait for Jupyter to start
sleep 10

# Get external IP
EXTERNAL_IP=$(curl -s ifconfig.me)


echo "🔍 Verifying Jupyter is accessible..."
timeout 30 bash -c 'until curl -s http://localhost:8888 > /dev/null; do sleep 2; done' && echo "✅ Jupyter responding" || echo "⚠️ Jupyter may need more time"


echo "=========================================="
echo "🎉 NASS Analysis Environment Ready!"
echo "=========================================="
echo "✅ Debian Bookworm configured"
echo "✅ R $(R --version | head -1 | cut -d' ' -f3) installed"
echo "✅ Python $(python3 --version | cut -d' ' -f2) installed"
echo "✅ Jupyter Lab running"
echo "✅ NASS notebook downloaded"
echo ""
echo "🔗 Access your analysis at:"
echo "   http://$EXTERNAL_IP:8888"
echo ""
echo "📝 Files located at: /opt/nass"
echo "📋 Logs available at: /var/log/jupyter.log"
echo ""
echo "🔧 Service commands:"
echo "   systemctl status jupyter-nass"
echo "   systemctl restart jupyter-nass"
echo ""
echo "Setup completed at: $(date)"
echo "=========================================="