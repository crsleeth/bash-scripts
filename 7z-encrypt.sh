#!/bin/bash

7za a -tzip -p$2 -mem=AES256 "${1%%/}.7z" "$1"

exit 0
