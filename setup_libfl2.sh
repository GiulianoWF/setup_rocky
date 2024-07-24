#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download flex
wget https://github.com/westes/flex/files/981163/flex-2.6.4.tar.gz

# Extract the archive
tar xzf flex-2.6.4.tar.gz

# Enter the flex directory
cd flex-2.6.4

# Configure the build
./configure --prefix=/usr

# Build flex
make

# Install flex
sudo make install

# Update the shared library cache
sudo ldconfig

# Clean up
cd /
rm -rf "$TEMP_DIR"

echo "Flex 2.6.4 has been installed successfully!"
