#!/bin/bash
#SBATCH -t 00-24:00:00
#SBATCH -N 1
#SBATCH -o stdout_preview_seq_%j
#SBATCH -e stderr_preview_seq_%j 
#SBATCH --job-name preview_seq
#SBATCH --mail-user mj2770@berkeley.edu
#SBATCH --mail-type=ALL
#SBATCH -A careswwm

# Lines starting with #SBATCH are for SLURM job management systems
# and may be removed if it is not submitting to SLURM

####################################################################
#
# STEP_5_1_Assembling_raw.sh
# Version 1 created June 2023 by Minxi Jiang
#
####################################################################
#
# This script is the assembling step using all the cleaned deduped
# raw reads
#
#   5. Assembling_raw

####################################################################

start=$SECONDS

# Source the bashrc file or set the PATH to make any functions or variables defined
# available in the current script

module load python/3.10.8

# Set the full path to SPAdes executable
SPADES_PATH=/p/lustre1/preview/seq_software/SPAdes-3.15.5-Linux/bin/spades.py

# Set the input and output directory paths
INPUT_DIR=/p/lustre1/preview/seq_data/output/STEP_1_QC_Trim/SPAdes/Trial
OUT_DIR=/p/lustre1/preview/seq_data/output/STEP_5_1_Assembling_deduped

#####################################################################
# Check if the output directory exists; if not, create it
mkdir -p "$OUT_DIR"

# Iterate over input files  
for f in "$INPUT_DIR"/*".forward.paried.deduped.fastq"; do
  # Check if the input file exists
  if [ ! -f "$f" ]; then
    echo "Input file not found: $f"
    continue
  fi

  # Extract the reverse read filename by replacing "forward" with "reverse"
  r="${f/forward/reverse}"

  # Set up the output file names
  output_name=$(basename "$f" .forward.paried.deduped.fastq)

  # Execute SPAdes command
  python3 "$SPADES_PATH" --meta -1 "$f" -2 "$r" -o "$OUT_DIR/$output_name.assembled"
done

end=$SECONDS
duration=$(( end - start ))
echo "STEP_5_1 took $duration seconds to complete"