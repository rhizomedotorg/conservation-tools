#!/bin/bash

sites=(`ls | grep txt`)

for x in ${sites[*]}
do
	if [ "${#x}" -gt "8" ]
	then
		w=${x:0:5}
	else
		w=${x:0:4}
	fi
	wget -e dirstruct=on --convert-links --warc-file=$w --warc-header="Operator: Alexander Duryee" --random-wait --wait=5 --directory-prefix=$w --input=$x
done
