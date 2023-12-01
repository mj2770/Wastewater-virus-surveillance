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
# STEP_1_QC_v4.sh
# Version 4 created June 2nd 2023 by Minxi Jiang
#
####################################################################
#
# This script the first STEP of QC trim within the overall proposed 
# bioinformatics analysis pipeline:
#
#   1. QC trim of the raw data
#  
#    1.1 Read cleaning with bbduk (remove adapters, qtrim sliding window, minlength)
#    1.2 Deduplication using seqkit
#    1.3 Paired the deduped reads and store the unpaired reads
#    1.4 Statistical analysis of the raw, cleaned and deduped reads using seqkit stats
#
####################################################################



####################################################################
start=$SECONDS

# source bashrc file or set the PATH to make any functions or variables defined
# available in the current test script

export PATH=/p/lustre1/preview/seq_software/:/p/lustre1/preview/seq_software/bbmap/:$PATH


# VARIABLES - set starting location and starting files location pathways
INPUT_DIR=/p/lustre1/preview/seq_data/input
OUT_DIR=/p/lustre1/preview/seq_data/output

####################################################################
#STEP 0: create/read checkpoint

printf "\nStep 0: Checking for the presence of the checkpoint file.\n"
if [ ! -f "$INPUT_DIR/checkpoints" ]
  then
    printf "\tThe file 'checkpoints' does not exist in the input directory, creating...\n"
    touch "$INPUT_DIR/checkpoints"
else
    printf "\tThe file 'checkpoints' already exists in the input directory.\n"
fi

#####################################################################

#STEP 1.1: QC TRIM BBDUK (sliding windows)

mkdir -p $OUT_DIR/STEP_1

Step=$(grep "bbduk" $INPUT_DIR/checkpoints)
if [ "${Step}" != "bbduk" ]
  then	
  
#All our input were paired files

for f in $INPUT_DIR/*R1*q.gz; do

    # find the reverse reads 
    f2=$(echo $f | awk -F "R1" '{print $1 "R2" $2}')
	
	# set up the output file names
    out_path=$(echo $f | awk -F "_R1" '{print $1 "_cleaned"}')
    
	# bbduk (seperate bbduk and dedupe, could add the parallel job submission format later)
        
	bbduk.sh in1=$f in2=$f2 out1=$out_path".forward" out2=$out_path".reverse" \
    outm1=$out_path".forward.unpaired" outm2=$out_path".reverse.unpaired" \
    ref=adapters ktrim=r k=23 mink=11 hdist=1 qtrim=r:4:10 tpe tbo minlen=70 
        
done

    mv $INPUT_DIR/*"_cleaned.forward"* $OUT_DIR/STEP_1
    mv $INPUT_DIR/*"_cleaned.reverse"* $OUT_DIR/STEP_1
	mv $INPUT_DIR/*"_cleaned.forward.unpaired"* $OUT_DIR/STEP_1
    mv $INPUT_DIR/*"_cleaned.reverse.unpaired"* $OUT_DIR/STEP_1

printf "BBDUK\n" >> "$INPUT_DIR/checkpoints"

else 
  printf  "\tThe variable bbduk is in the checkpoint file. STEP 1.1 will be skipped.\n"
fi

#STEP 1.2: Remove the duplications with seqkit 
Step=$(grep "seqkit" $INPUT_DIR/checkpoints)
if [ "${Step}" != "seqkit" ]
  then

for cleaned_file in $OUT_DIR/STEP_1/*_cleaned.forward; do 

    # Get the file name without the extension
    filename=$(basename "$cleaned_file" _cleaned.forward)
    
    # Deduplicate the forward file
    seqkit rmdup -s "$cleaned_file" -o "$OUT_DIR/STEP_1/$filename.forward.deduped"
    
    # Deduplicate the corresponding reverse file
    seqkit rmdup -s "${cleaned_file%_cleaned.forward}_cleaned.reverse" -o "$OUT_DIR/STEP_1/$filename.reverse.deduped"
done

printf "seqkit\n" >> "$INPUT_DIR/checkpoints"

else
  printf  "\tThe variable seqkit is in the checkpoint file. STEP 1.2 will be skipped.\n"
fi


# STEP 1.3 Paired the cleaned deduped reads and store the unpaired reads
# Note: These are used later for statistical analysis.
Step=$(grep "Paired" $INPUT_DIR/checkpoints)
if [ "${Step}" != "Paired" ]
  then

# Define the output directory
output_dir="$OUT_DIR/STEP_1"

# Loop through each pair of files in the input directory
for forward_file in "$OUT_DIR/STEP_1/"/*.forward.deduped; do
    # Get the corresponding reverse file
    reverse_file="${forward_file/forward/reverse}"

    # Extract the filename without the directory path
    filename=$(basename "$forward_file")

    # Run seqkit pair command
    seqkit pair -1 "$forward_file" -2 "$reverse_file" -O "$output_dir" -u 
done

printf "Paired\n" >> "$INPUT_DIR/checkpoints"

else
  printf  "\tThe variable Paired is in the checkpoint file. STEP 1.3 will be skipped.\n"
fi

# STEP 1.4 Getting the statistics of raw,cleaned, and deduped reads
# Note: These are used later for statistical analysis.
Step=$(grep "stats" $INPUT_DIR/checkpoints)
if [ "${Step}" != "stats" ]
  then

# Set three output file path
Stats_cleaned="$OUT_DIR/STEP_1/cleaned_stats.txt"
Stats_deduped="$OUT_DIR/STEP_1/deduped_stats.txt"
Stats_paired="$OUT_DIR/STEP_1/paired_stats.txt"
Stats_raw="$OUT_DIR/STEP_1/raw_stats.txt"

# Loop through the files with the specified extensions
for file in $OUT_DIR/STEP_1/*_cleaned*; do
    # Get the file name without the extension
    filename=$(basename "$file" _cleaned*)
    
    # Run SeqKit stats and save the output to a temporary file
    seqkit stats -j 100 "$file" -a > "temp_stats.txt"
    
    # Append the file name to the temporary file
    echo "File: $filename" >> "temp_stats.txt"
    
    # Append a newline character to separate entries
    echo >> "temp_stats.txt"
    
    # Append the contents of the temporary file to the output file
    cat "temp_stats.txt" >> "$Stats_cleaned"
    
    # Remove the temporary file
    rm "temp_stats.txt"
done

# Loop through the files with the specified extensions
for file in $OUT_DIR/STEP_1/*.deduped*; do
    # Get the file name without the extension
    filename=$(basename "$file" .deduped)
    
    # Run SeqKit stats and save the output to a temporary file
     seqkit stats -j 100 "$file" -a > "temp_stats_1.txt"
    
    # Append the file name to the temporary file
    echo "File: $filename" >> "temp_stats_1.txt"
    
    # Append a newline character to separate entries
    echo >> "temp_stats_1.txt"
    
    # Append the contents of the temporary file to the output file
    cat "temp_stats_1.txt" >> "$Stats_deduped"
    
    # Remove the temporary file
    rm "temp_stats_1.txt"
done

# Loop through the files with the specified extensions
for file in $OUT_DIR/STEP_1/*.paired.*; do
    # Get the file name without the extension
    filename=$(basename "$file" .paired*)
    
    # Run SeqKit stats and save the output to a temporary file
     seqkit stats -j 100 "$file" -a > "temp_stats_2.txt"
    
    # Append the file name to the temporary file
    echo "File: $filename" >> "temp_stats_2.txt"
    
    # Append a newline character to separate entries
    echo >> "temp_stats_2.txt"
    
    # Append the contents of the temporary file to the output file
    cat "temp_stats_2.txt" >> "$Stats_paired"
    
    # Remove the temporary file
    rm "temp_stats_2.txt"
done

# Loop through the files with the specified extensions
for file in $INPUT_DIR/*fastq.gz; do
    # Get the file name without the extension
    filename=$(basename "$file" .fastq.gz)
    
    # Run SeqKit stats and save the output to a temporary file
     seqkit stats -j 100 "$file" -a > "temp_stats_3.txt"
    
    # Append the file name to the temporary file
    echo "File: $filename" >> "temp_stats_3.txt"
    
    # Append a newline character to separate entries
    echo >> "temp_stats_3.txt"
    
    # Append the contents of the temporary file to the output file
    cat "temp_stats_3.txt" >> "$Stats_raw"
    
    # Remove the temporary file
    rm "temp_stats_3.txt"
done

printf "stats\n" >> "$INPUT_DIR/checkpoints"

else
  printf  "\tThe variable stats is in the checkpoint file. STEP 1.4 will be skipped.\n"
fi

####################################################################
end=$SECONDS
duration=$(( end - start ))
echo "STEP_1 took $duration seconds to complete"