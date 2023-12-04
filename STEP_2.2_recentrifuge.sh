#!/bin/bash 
#SBATCH -t 00-24:00:00
#SBATCH -N 1
#SBATCH -o stdout_rcf_50
#SBATCH -e stderr_rcf_50
#SBATCH --job-name rcf_50
#SBATCH --mail-user mulakken1@llnl.gov
#SBATCH --mail-type=ALL
#SBATCH -A careswwm


## Winter 2023 decon
taxonomy_dir=/p/lustre2/metagen/dbs/nt_wntr23/bld/taxonomy
cfout_path=/p/lustre1/preview/seq_data/output/STEP_2

MHL=40
rcf_insall_path=/usr/workspace/invisorg/Task1/recentrifuge

for f1 in  $cfout_path/*.out
do
  $rcf_insall_path/rcf -n $taxonomy_dir -f $f1 -e TSV -o "$(basename $f1 _mhl22.out)_mhl$MHL.out" -y $MHL
done





