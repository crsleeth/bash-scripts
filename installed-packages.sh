#!/bin/bash

# This script lists packages that have been installed on Ubuntu post-install. 
# It excludes packages that come pre-installed on Ubuntu, or were installed 
# from Ubuntu Server's "Software selection" installation step. Only tested on 
# Ubuntu 14 and 16.

comm -23 <(apt-mark showmanual | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)

exit 0
