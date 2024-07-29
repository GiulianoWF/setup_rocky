#!/bin/bash

FUSION_LIB="/opt/fusion/x86_64/debug/1.0.0.0.0/libfusion-apache-front-controller.so"

# Install Apache and development libraries
dnf install httpd httpd-devel -y

if [ ! -f "$FUSION_LIB" ]; then
    echo "Fusion library not found. Installing only httpd.h library."
    exit 0
fi

# If we reach here, it means the Fusion library was found
echo "Fusion library found. Configuring full setup."

# Start and enable Apache service
systemctl start httpd
systemctl enable httpd

# Configure firewall
firewall-cmd --permanent --add-service=http
firewall-cmd --reload

# Create symbolic link for mod_fusion.so
mkdir -p /etc/httpd/modules
ln -sf "$FUSION_LIB" /etc/httpd/modules/mod_fusion.so

# Add LoadModule directive to 00-base.conf if not already present
if ! grep -q "LoadModule fusionfrontcontroller modules/mod_fusion.so" /etc/httpd/conf.modules.d/00-base.conf; then
    echo "LoadModule fusionfrontcontroller modules/mod_fusion.so" >> /etc/httpd/conf.modules.d/00-base.conf
fi

# Set SELinux boolean
setsebool -P httpd_execmem 1

# Generate and install SELinux policy module (only if there are recent denials)
if ausearch -c 'httpd' --raw | audit2allow -M my-httpd; then
    semodule -X 300 -i my-httpd.pp
else
    echo "No recent SELinux denials for httpd found. Skipping policy module creation."
fi

# Create or update redirect_http.conf
cat << EOF > /etc/httpd/conf.d/redirect_http.conf
<Location "/fusion/">
SetHandler fusionfrontcontroller
Require all granted
</Location>
EOF

# Check Apache configuration
if httpd -t; then
    echo "Apache configuration is valid."
    # Restart Apache
    systemctl restart httpd
else
    echo "Apache configuration is invalid. Please check your configuration files."
    exit 1
fi

# SELinux will not let the fusion-app-bootstraper connect to apache. The simple solution is to disable it
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

echo "Full Apache configuration for Fusion completed."
