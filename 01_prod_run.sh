#!/bin/sh
set -eu
for id in `seq 1 8`; do
    sed -e "s/#{RUN_ID}/${id}/g" template_exe_prod.sh > prod_${id}.sh
    pjsub prod_${id}.sh
    sleep 1
done
