#!/bin/bash
#SBATCH -t 00-24:00:00
#SBATCH -N 1
#SBATCH -o stdout_preview_seq_%j
#SBATCH -e stderr_preview_seq_%j 
#SBATCH --job-name preview_seq
#SBATCH --mail-user mj2770@berkeley.edu
#SBATCH --mail-type=ALL
#SBATCH -A careswwm

# Path to samtools
SAMTOOLS_PATH="/p/lustre1/preview/seq_software/samtools-1.17/samtools"

# Path to iVar
IVAR_PATH="/p/lustre1/preview/seq_software/bin/ivar"

# Input and reference paths
input_bam="/p/lustre1/preview/seq_data/output/STEP_6_Variants_calling/JC_virus/Bowtie2_IP/sorted_aligned_IP.bam"
reference="/p/lustre1/preview/seq_data/output/STEP_6_Variants_calling/JC_virus/NODE_2_length_5197_cov_19.468359_PMG_301_3.fasta"
output_dir="/p/lustre1/preview/seq_data/output/STEP_6_Variants_calling/ivar_JC_virus/"

# Extract the sample name from the input BAM filename
sample_name=$(basename "${input_bam%.*}" | sed 's/sorted_aligned_//')

# Define output VCF filename
output_vcf="${sample_name}_variant_call_trial.pass.vcf"

# Run samtools mpileup and pipe the output to ivar variants
$SAMTOOLS_PATH mpileup -A -B -Q 0 -f "$reference" "$input_bam" | \
$IVAR_PATH variants -p "$sample_name"_variant_call -q 10 -t 0.01 -m 10 -r "$reference"

