#!/bin/sh
#PJM -L rscgrp=a-pj24003126
#PJM -L node=1
#PJM -L elapse=168:00:00
#PJM -j
module load intel
module load impi
## export OMP_NUM_THREADS=12

. /etc/profile.d/modules.sh
source $HOME/miniforge3/bin/activate
source $HOME/apps/gromacs/2022.5/set_env.sh
set -eu 

GMX=gmx_mpi
#ntomp=12

echo "Equilibriation at NVT"
${GMX} grompp -maxwarn 1 -o nvt_eq_#{RUN_ID}.tpr -f inputs/nvt_eq.mdp -p system.top -c em2.gro -po mdout_nvt_eq_#{RUN_ID}.mdp
${GMX} mdrun -deffnm nvt_eq_#{RUN_ID} #-ntomp $ntomp

echo "Equilibriation at NPT"
${GMX} grompp -maxwarn 1 -o npt_eq_#{RUN_ID}.tpr -f inputs/npt_eq.mdp -p system.top -c nvt_eq_#{RUN_ID}.gro -po mdout_npt_eq_#{RUN_ID}.mdp
${GMX} mdrun -deffnm npt_eq_#{RUN_ID} #-ntomp $ntomp

echo "Production runs at NPT"
${GMX} grompp -maxwarn 1 -o npt_prod_#{RUN_ID}.tpr -f inputs/npt_prod.mdp -p system.top -c npt_eq_#{RUN_ID}.gro -po mdout_npt_prod_#{RUN_ID}.mdp
${GMX} mdrun -deffnm npt_prod_#{RUN_ID} # -ntomp $ntomp
