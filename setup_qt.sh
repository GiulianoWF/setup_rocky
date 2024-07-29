#!/bin/bash

dnf update
dnf install -y epel-release
dnf install -y qt5-qtbase-devel
ln -s /usr/lib64/qt5/bin/qmake /usr/bin/qmake


dnf -y install qt5-qtwebkit
#dnf install qt5-qtwebkit-dev
dnf -y install qt5-qtwebengine-devtools
dnf -y install qt5-qtwebengine-devel
dnf -y install qt5-qtwebkit-devel

# Setup no sandbox to enable qt to run

# Check and add QTWEBENGINE_CHROMIUM_FLAGS to sudoers if not already present
if ! grep -q "Defaults env_keep += \"QTWEBENGINE_CHROMIUM_FLAGS\"" /etc/sudoers; then
    echo 'Defaults env_keep += "QTWEBENGINE_CHROMIUM_FLAGS"' | EDITOR='tee -a' visudo
fi

# Check and create qt_flags.sh if it doesn't exist
if [ ! -f "/etc/profile.d/qt_flags.sh" ]; then
    echo 'export QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox"' > /etc/profile.d/qt_flags.sh
fi
