#!/bin/bash
#SBATCH -t 00-24:00:00
#SBATCH -N 1
#SBATCH -o stdout_preview_seq_%j
#SBATCH -e stderr_preview_seq_%j 
#SBATCH --job-name preview_seq
#SBATCH --mail-user mj2770@berkeley.edu
#SBATCH --mail-type=ALL
#SBATCH -A careswwm

module load python/3.10.8
# Set the full path to the best.py script
SCRIPT_PATH="/p/lustre1/preview/seq_data/output/STEP_5_Assembling_Blast/STEP_5_6_QC_select_scaffolds/virsorter2/Best_hits_per_node/best.py"

input="/p/lustre1/preview/seq_data/output/STEP_5_Assembling_Blast/STEP_5_4_Blastn/virsorter2_virus/"
output="/p/lustre1/preview/seq_data/output/STEP_5_Assembling_Blast/STEP_5_6_QC_select_scaffolds/virsorter2/Best_hits_per_node/"

# Iterate over each file in the directory
for file in "${input}"*_blastn_good.txt; do
    if [[ -f $file ]]; then
        # Get the filename without the directory path and remove the extension
        base_name=$(basename "$file" _blastn_good.txt)

        # Run the Python script to select the best hits
        python3 "$SCRIPT_PATH" "$file" "$output" "$base_name"

        echo "Saved best hits to: ${base_name}_best_hits.blastn"
    fi
done
