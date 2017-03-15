#!/bin/bash

for i in */
do
	7za a -tzip -p$1 -mem=AES256 "${i%/}.7z" "$i"
done

exit 0
