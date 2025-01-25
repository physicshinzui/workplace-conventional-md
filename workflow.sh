#!/bin/bash 
set -eu 
cat << EOF
Usage: 
    $0 [Input PDB]
EOF
pdb=$1
./01_system_prep.sh $pdb
./02_prepare_preprocess_top.sh
read -p 'Add an underline after atomtypes in the top file. ENTER'
vim processed.top
qsub 03_exe_rest2.sh
