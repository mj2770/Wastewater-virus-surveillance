#!/bin/bash
#SBATCH -t 00-24:00:00
#SBATCH -N 1
#SBATCH -o stdout_preview_seq_%j
#SBATCH -e stderr_preview_seq_%j
#SBATCH --job-name=preview_seq
#SBATCH --mail-user mj2770@berkeley.edu
#SBATCH --mail-type=ALL
#SBATCH -A careswwm

module load python/3.10.8

# Set the full path to QC_select.py script
QC_PATH=/p/lustre1/preview/seq_data/output/STEP_5_Assembling_Blast/STEP_5_6_QC_select_scaffolds/virsorter2/QC_select_2.py

# Define the input directory of the BLASTN output files
directory="/p/lustre1/preview/seq_data/output/STEP_5_Assembling_Blast/STEP_5_4_Blastn/virsorter2_virus/"

# Define the QC criteria
min_identity=80.0
min_alignment_length=1000
max_evalue=1E-8
min_coverage=10

# Iterate over each file in the directory
for file in "$directory"*_blastn_good.txt; do
    if [[ -f $file ]]; then
        # Get the filename without the directory path
        filename=$(basename "$file")

        # Remove the file extension to get the base name
        base_name="${filename%.*}"

        # Run the Python script to select the good quality reads and save the IDs
        python3 "$QC_PATH" "$file" "$directory" "$min_identity" "$min_alignment_length" "$max_evalue" "$min_coverage" "$base_name"

        echo "Saved selected IDs to: ${base_name}_1000bp_cov10.txt"
    fi
done

