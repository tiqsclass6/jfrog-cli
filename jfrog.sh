#!/bin/bash

# Ensure JFROG_SERVER_ID is set
JFROG_SERVER_ID="artifactory-server"

# Ensure JFrog CLI is installed in the expected path
JFROG_CLI_PATH="$HOME/.local/bin/jfrog"

# Load Jenkins credentials from environment variables
JFROG_USER=${JFROG_USER}
JFROG_PASSWORD=${JFROG_PASSWORD}

# Check if JFrog CLI is installed
if ! command -v "$JFROG_CLI_PATH" &> /dev/null; then
    echo "Error: JFrog CLI is not installed. Exiting."
    exit 1
fi

# Configure JFrog Artifactory
if "$JFROG_CLI_PATH" config show "$JFROG_SERVER_ID" > /dev/null 2>&1; then
    echo "Updating existing JFrog configuration..."
    "$JFROG_CLI_PATH" config edit "$JFROG_SERVER_ID" --interactive=false <<EOF
$JFROG_USER
$JFROG_PASSWORD
EOF
else
    echo "Adding new JFrog configuration..."
    "$JFROG_CLI_PATH" config add "$JFROG_SERVER_ID" \
        --artifactory-url=https://trialu79uyt.jfrog.io/artifactory \
        --user="$JFROG_USER" --password="$JFROG_PASSWORD" --interactive=false
fi