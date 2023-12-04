#!/bin/bash
#SBATCH -t 00-24:00:00
#SBATCH -N 1
#SBATCH -o stdout_preview_seq_%j
#SBATCH -e stderr_preview_seq_%j
#SBATCH --job-name preview_seq
#SBATCH --mail-user mj2770@berkeley.edu
#SBATCH --mail-type=ALL
#SBATCH -A careswwm

source /p/lustre1/preview/seq_software/prefix=mamba/virsorter2/bin/activate

cd /p/lustre1/preview/seq_data/output/STEP_10_virsorter2/

virsorter run --prep-for-dramv -w NT_419_3_full_assemble_all_scaffolds.out -i /p/lustre1/preview/seq_data/output/STEP_5_Assembling_Blast/STEP_5_1_fullassemble/Finished/NT/NT_0419_3_S15_L002.assembled/scaffolds.fasta --include-groups "dsDNAphage,lavidaviridae,NCLDV,RNA,ssDNA" -j 128 all
done
