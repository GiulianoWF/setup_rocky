#!/bin/bash

# install lib -lssl and -lcrypto
dnf -y install openssl-devel
# install lib -lcppunit
dnf --enablerepo=powertools -y install cppunit-devel
# install lib -ljpeg
dnf -y install libjpeg-turbo-devel
# install lib -lxml2
dnf -y install libxml2
# install lib -lxslt
dnf -y install libxslt-devel
# install lib -lfreetype
dnf -y install freetype-devel
# install lib -ludev
dnf -y install systemd-devel
# install lib -lpci
dnf --enablerepo=powertools -y install pciutils-devel
# install lib -lpciaccess
dnf -y install libpciaccess-devel
# install lib -lkmod
dnf --enablerepo=powertools -y install kmod-devel
# install lib -lXi
dnf -y install libXi-devel
# install lib -lsqlite3
dnf -y install sqlite-devel
# install lib -lcurl
dnf -y install libcurl-devel
# install lib  libfl.so.2
./setup_libfl2.sh
# install lib -llog4cpp
dnf -y install log4cpp-devel
# install lib -lusb
./setup_libusb-v0_1.sh
# install lib -ldb-6
dnf --enablerepo=powertools -y install libdb-cxx-devel
ln -s /usr/lib64/libdb-5.3.so /usr/lib64/libdb-6.so
# install lib -lXrandr
dnf -y install libXrandr-devel
# install lib -lasound
dnf -y install alsa-lib-devel
# fix xlocale
ln -s /usr/include/locale.h /usr/include/xlocale.h
