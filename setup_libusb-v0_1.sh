#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download libusb-compat-0.1
wget https://github.com/libusb/libusb-compat-0.1/archive/refs/tags/v0.1.7.tar.gz

# Extract the archive
tar xzf v0.1.7.tar.gz

# Enter the libusb directory
cd libusb-compat-0.1-0.1.7

# Install necessary build tools
sudo dnf group install -y "Development Tools"
sudo dnf install -y libtool automake

# Configure the build
./bootstrap.sh
./configure --prefix=/usr/local --disable-shared --enable-static

# Build libusb
make

# Install libusb
sudo make install

# Update the shared library cache
sudo ldconfig

# Clean up
cd /
rm -rf "$TEMP_DIR"

echo "libusb-0.1 (compat) has been installed successfully!"
