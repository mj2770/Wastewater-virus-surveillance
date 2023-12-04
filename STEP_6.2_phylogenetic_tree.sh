#!/bin/bash
#SBATCH -t 00-24:00:00
#SBATCH -N 1
#SBATCH -o stdout_preview_seq_%j
#SBATCH -e stderr_preview_seq_%j
#SBATCH --job-name preview_seq
#SBATCH --mail-user mj2770@berkeley.edu
#SBATCH --mail-type=ALL
#SBATCH -A careswwm


# Specify the full paths for MUSCLE and FastTree
MUSCLE_PATH="/p/lustre1/preview/seq_software/muscle"
FASTTREE_PATH="/p/lustre1/preview/seq_software/FastTree"

# Go to the working directory
cd /p/lustre1/preview/seq_data/output/STEP_9_Phylogenetic_Tree/JC/

# Perform Multiple Sequence Alignment (MSA) with MUSCLE
#$MUSCLE_PATH -in hopefully_final.fas -out hopefully_final_MUSCLE.fasta

# Generate Phylogenetic Tree with FastTree
$FASTTREE_PATH  -nt -gtr -boot 100 align_cured_Gblock_2.fas > 10_3_Gblock.nwk

echo "MUSCLE alignment and fasttree buildup successfully."
