#!/bin/bash
set -eu

jobs=`pjstat | awk '{print $1}'`
i=0
for job in $jobs;do
    if [ $i -eq 0 ]; then
        i=1
        continue
    fi
    echo $job
    pjdel $job
    sleep 0.5
done
