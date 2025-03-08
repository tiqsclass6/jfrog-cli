#!/bin/bash

# Set Build Name with Current Date
BUILD_NAME="jfrog_jenkins_$(date +%d%m%y)"
echo "JFROG_BUILD_NAME=$BUILD_NAME" >> $GITHUB_ENV

# Get System Architecture for Trivy
TRIVY_ARCHIVE="trivy_$(uname -s)_$(uname -m).tar.gz"
echo "TRIVY_ARCHIVE=$TRIVY_ARCHIVE" >> $GITHUB_ENV

# Display Values
echo "Initialized Variables:"
echo "JFROG_BUILD_NAME=$BUILD_NAME"
echo "TRIVY_ARCHIVE=$TRIVY_ARCHIVE"