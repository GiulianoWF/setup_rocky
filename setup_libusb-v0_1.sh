#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

# Install necessary build tools
sudo dnf group install -y "Development Tools"
sudo dnf install -y libtool automake

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download libusb-0.1.12
wget https://sourceforge.net/projects/libusb/files/libusb-0.1%20%28LEGACY%29/0.1.12/libusb-0.1.12.tar.gz

# Extract the archive
tar xzf libusb-0.1.12.tar.gz

# Enter the libusb directory
cd libusb-0.1.12

export CFLAGS="-Wno-error=format-truncation -Wno-format-truncation"

# Configure the build
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

echo "libusb-0.1.12 has been installed successfully!"
