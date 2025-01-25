#!/bin/bash 
set -eu 
for rep in `ls -d rep*`; do
    echo $rep
    mv $rep prerun_$rep
done
