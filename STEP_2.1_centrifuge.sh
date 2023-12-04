#!/bin/bash 
#SBATCH -t 00-24:00:00
#SBATCH -N 1
#SBATCH -o stdout_cf
#SBATCH -e stderr_cf
#SBATCH --job-name cf 
#SBATCH --mail-user mulakken1@llnl.gov
#SBATCH --mail-type=ALL
#SBATCH -A careswwm

config=/p/lustre1/preview/seq_data/output/STEP_2/cfg_samples.tsv
cf_path=/usr/workspace/invisorg/Task1/cfg/bin
export OMP_NUM_THREADS=256

time $cf_path/centrifuge -x  /p/lustre2/metagen/dbs/nt_wntr23/bld/nt_wntr23 --sample-sheet $config -p 256 -t --min-hitlen 15 -k 1

retval=$?

if [ $retval -ne 0 ]; then
  echo 'CFG FAILED!!!'
else
  echo 'CFG OK!'
fi
exit $retval



