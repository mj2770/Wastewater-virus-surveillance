#!/bin/bash
#SBATCH -t 00-24:00:00
#SBATCH -N 1
#SBATCH -o stdout_blastn_%j
#SBATCH -e stderr_blastn_%j
#SBATCH --job-name blastn
#SBATCH --mail-user mj2770@berkeley.edu
#SBATCH --mail-type=ALL
#SBATCH -A careswwm

# Set the blastn and db paths
blastn_path="/p/lustre1/preview/seq_software/ncbi-blast-2.14.0+/bin/blastn"
db_path="/p/lustre1/preview/seq_data/Ref_data/Blast/nt_viruses"

# Input directory
input_dir="/p/lustre1/preview/seq_data/output/STEP_10_virsorter2/"

# Set the output directory
output_dir="/p/lustre1/preview/seq_data/output/STEP_5_Assembling_Blast/STEP_5_4_Blastn/virsorter2_virus/"

# Iterate over input files
for input_file in "${input_dir}"/*_virsorter.out/final-viral-combined.fa; do
    # Get the sample name from input file path
    sample_name=$(basename "$(dirname "$input_file")" | sed 's/_virsorter\.out$//')

    # Set the output file names
    blastn_output="${output_dir}/${sample_name}_blastn_good.txt"
    virus_scaffolds_file="${output_dir}/${sample_name}_virus_good_scaffolds.fasta"
    virus_scaffolds_stats="${output_dir}/${sample_name}_virus_good_scaffolds_stats.txt"

    # Perform blastn
    "$blastn_path" -query "$input_file" -db "$db_path" -out "$blastn_output" -outfmt 6 -perc_identity 80 -evalue 0.00000001 -max_hsps 1 -qcov_hsp_perc 90 -num_threads 128

    # Extract virus-aligned scaffolds
    virus_scaffold_ids=$(awk '{print $1}' "$blastn_output" | sort -u)
    seqkit grep -f <(echo "$virus_scaffold_ids") "$input_file" > "$virus_scaffolds_file"

done



