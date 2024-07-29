#!/bin/bash
# Install Ruby and development tools
dnf install -y ruby ruby-devel gcc make rpm-build rubygems

# Install PostgreSQL and SQLite development files
dnf install -y postgresql-devel sqlite-devel

# Install specific gems
gem install pg -v 0.18.4
gem install sqlite3 -v 1.4.2
