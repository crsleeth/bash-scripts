#!/bin/bash

for i in */
do
	7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on "${i%/}.7z" "$i"
done

exit 0
