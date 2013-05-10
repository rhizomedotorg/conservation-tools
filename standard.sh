#!/bin/bash
# standard.sh NUM URL
wget --user-agent="AmigaVoyager/3.2 (AmigaOS/MC680x0)" --warc-file=$1 --warc-header="Operator: Alexander Duryee" --directory-prefix=$1 --page-requisites -e robots=off --random-wait --wait=5 --recursive --level=0 --no-parent --convert-links $2
