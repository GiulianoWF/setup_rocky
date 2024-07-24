#!/bin/bash

dnf update
dnf install -y epel-release
dnf install -y qt5-qtbase-devel
ln -s /usr/lib64/qt5/bin/qmake /usr/bin/qmake


dnf -y install qt5-qtwebkit
#dnf install qt5-qtwebkit-dev
dnf -y install qt5-qtwebengine-devtools
dnf -y install qt5-qtwebengine-devel

