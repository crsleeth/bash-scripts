#!/bin/bash

# Tests disk write and then read speed. Must be ran as disk-speed <GB of RAM>. 
# For example: disk-speed 8 for 8GB of RAM.

ram=$((1024 * $1))
echo "Your computer's RAM amount is: $ram"

echo "Clearing cache..."
dd if=/dev/zero of=cachefile bs=1M count=$ram > /dev/null 2>$1

echo "Testing write speed..."
dd if=/dev/zero of=tempfile bs=1M count=1024

echo "Clearing cache..."
dd if=/dev/zero of=cachefile bs=1M count=$ram > /dev/null 2>$1

echo "Testing read speed..."
dd if=tempfile of=/dev/null bs=1M count=1024

echo "Clearing cache..."
dd if=/dev/zero of=cachefile bs=1M count=$ram > /dev/null 2>$1

rm cachefile
rm tempfile

exit 0
