#!/bin/bash

cat /var/log/apache2/access.log | awk '{print $1}' | sort -n | uniq -c | sort -nr | head -20

exit 0
