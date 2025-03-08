#!/bin/bash

set -e  # Stop on error

# Install wget if missing
if ! command -v wget &> /dev/null; then
    echo "wget not found. Installing..."
    if [ -f /etc/debian_version ]; then
        sudo apt-get update && sudo apt-get install -y wget
    elif [ -f /etc/redhat-release ]; then
        sudo yum install -y wget
    else
        echo "Unsupported OS. Install wget manually."
        exit 1
    fi
fi

# Define Trivy version and architecture
TRIVY_VERSION="0.47.0"
TRIVY_ARCHIVE="trivy_$(uname -s)_$(uname -m).tar.gz"

# Check if Trivy is already installed
if ! command -v trivy &> /dev/null; then
    echo "Downloading Trivy v$TRIVY_VERSION..."
    wget -O $TRIVY_ARCHIVE https://github.com/aquasecurity/trivy/releases/download/v$TRIVY_VERSION/$TRIVY_ARCHIVE

    echo "Verifying downloaded file..."
    file $TRIVY_ARCHIVE
    ls -lh $TRIVY_ARCHIVE

    echo "Extracting Trivy..."
    tar -xzf $TRIVY_ARCHIVE || (echo "Extraction failed. File might be corrupted." && exit 1)

    chmod +x trivy
    sudo mv trivy /usr/local/bin/trivy
    rm -f $TRIVY_ARCHIVE  # Clean up
else
    echo "Trivy is already installed."
fi

echo "Trivy installation completed successfully."
trivy --version