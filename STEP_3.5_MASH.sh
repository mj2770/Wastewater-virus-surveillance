#!/bin/bash
#SBATCH -t 00-24:00:00
#SBATCH -N 1
#SBATCH -o stdout_preview_seq_%j
#SBATCH -e stderr_preview_seq_%j 
#SBATCH --job-name preview_seq
#SBATCH --mail-user mj2770@berkeley.edu
#SBATCH --mail-type=ALL
#SBATCH -A careswwm

# Set up the environment and change to the recentrifuge directory
export PATH=/p/lustre1/preview/seq_software/recentrifuge:/p/lustre1/preview/seq_software/recentrifuge/taxdump/:$PATH
cd "/p/lustre1/preview/seq_software/recentrifuge/"

# Define the input directory, virus taxID and classification output from centrifuge
input_dir="/p/lustre1/preview/seq_data/output/STEP_1_QC_Trim/SPAdes/"

sample_id="10239"

classification_output_dir="/p/lustre1/preview/seq_data/output/STEP_2_Centrifuge/"

# Process each forward input file
for forward_file in "$input_dir"/*_L002.forward.paried.deduped.fastq; do
  # Construct the corresponding reverse filename
  reverse_file="${forward_file/_L002.forward/_L002.reverse}"

  # Construct the classification output filename
    classification_output="${classification_output_dir}/$(basename ${forward_file%.forward.paried.deduped.fastq}).out"

  # Run the rextract command for paired-end reads and virus sequences
  rextract -f "$classification_output" -i "$sample_id" -1 "$forward_file" -2 "$reverse_file"
done
