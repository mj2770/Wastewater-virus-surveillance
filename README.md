# Wastewater virus surveillance analysis pipeline  
This bioinformatic pipeline is used to analyze targeted sequencing data of viruses generated from total nucleic acid extracted from wastewater samples using various concentration/extraction methods. The sequencing library was prepared with the Illumina Virus Surveillance Panel (probe-capture enrichment) and paired with RNA preparation using Enrichment and Tagmentation kits.

Notes - This Repo is still under active development and please refer to the updated version. 

## Introduction
This pipeline takes FASTQ files as input and includes both read-based and assembly-based virus classification. Before classification, quality control (QC) is performed, followed by deduplication to generate unique reads. The read-based analysis identifies viruses using Centrifuge and Recentrifuge, and the classified taxIDs were used for retrieving the virus-host information from NCBI taxonomy. The assembly-based classification involves full assembly by SPAdes, virus classification by Virsorter2, and subsequent Blastn against the NCBI nt virus database. The resulting near-complete virus genomes are utilized for phylogenetic analysis and variant calling.

Dataset and code for the manuscript: Evaluation of the impact of concentration and extraction methods on the targeted sequencing of human viruses from wastewater

## Download database and dependencies
### 1. Raw sequencing data 
All are deposited in the NCBI Sequence Read Archive (SRA) under accession number: SUB13892842 and Bioproject ID: PRJNA1047067.
### 2. Database
   * Refseq virus: download using [Entrez](https://www.ncbi.nlm.nih.gov/books/NBK25501/)
     ```
     "Viruses"[Organism] NOT "cellular organisms"[Organism] NOT wgs[PROP] NOT gbdiv syn[prop] AND (srcdb_refseq[PROP] OR nuccore genome samespecies[Filter])
     ```
   * [NCBI nt-virus](https://ftp.ncbi.nlm.nih.gov/blast/db/)
   * Centrifuge and Recentrifuge default database: [NCBI nt decontaminated version](https://github.com/khyox/recentrifuge/wiki/Centrifuge-nt)
### 3. Dependent packages
   * [BBduk from the BBTools suite](https://jgi.doe.gov/data-and-tools/software-tools/bbtools/bb-tools-user-guide/bbduk-guide/)
   * [Seqkit](https://github.com/shenwei356/seqkit/blob/master/README.md)
   * [Centrifuge and Recentrifuge](https://github.com/khyox/recentrifuge/wiki/Running-recentrifuge-for-Centrifuge) 
   * [MASH](https://github.com/marbl/Mash): Fast genome and metagenome distance estimation using MinHash 
   * Jupyter notebook: pandas, numpy, plotnine, seaborn, scipy.spatial etc. (All python scripts were uploaded as google colab scripts)
   * [bowtie2 (v2.5.1)](https://github.com/BenLangmead/bowtie2), [Samtools, bcftools, and htslib](https://www.htslib.org/download/) 
   * [VirSorter2 (v2.2.4)](https://github.com/jiarong/VirSorter2#detailed-description-on-output-files) 
   * BLASTn (v2.14.0+)
   * [MUSCLE](https://github.com/rcedgar/muscle) and [Gblock 0.91b](http://phylogeny.lirmm.fr/phylo_cgi/one_task.cgi?task_type=gblocks)
   * [Instrain](https://github.com/MrOlm/inStrain/blob/master/docs/user_manual.rst)
   * [Dataset](https://www.ncbi.nlm.nih.gov/datasets/docs/v2/download-and-install/) and [Dataformat](https://www.ncbi.nlm.nih.gov/datasets/docs/v2/reference-docs/command-line/dataformat/)

## Basic analysis pipeline
### STEP 1. Quality control 
Step 1.1 Quality filter of raw reads
```
bbduk.sh in1=$f in2=$f2 out1=$out_path".forward" out2=$out_path".reverse" \
    outm1=$out_path".forward.unpaired" outm2=$out_path".reverse.unpaired" \
    ref=adapters ktrim=r k=23 mink=11 hdist=1 qtrim=r:4:10 tpe tbo minlen=70
```
Step 1.2 Dedupe the good quality reads
```
seqkit rmdup -s "$cleaned_file" -o "$OUT_DIR/STEP_1/$filename.forward.deduped"
```
Step 1.3 Paired the deduped reads
```
seqkit pair -1 "$forward_file" -2 "$reverse_file" -O "$output_dir" -u
```
Step 1.4 Statistical analysis of all reads
```
 seqkit stats -j 100 "$file" -a > "temp_stats.txt
```
### 2. Read-based classification by Centrifuge and Recentrifuge 
```
# Centrifuge
time $cf_path/centrifuge -x  /p/lustre2/metagen/dbs/nt_wntr23/bld/nt_wntr23 --sample-sheet $config -p 256 -t --min-hitlen 15 -k 1
# Recentrifuge
$rcf_insall_path/rcf -n $taxonomy_dir -f $f1 -e TSV -o "$(basename $f1 _mhl22.out)_mhl40.out" -y 40
```

### 3. Analysis of the read-based classification results
    * Taxonomy domain analysis 
   * Virus reads host-screen 
* Virus reads genotype analysis (DNA and RNA type)
     * Virus species richness and composition analysis 
     * Virus genome similarity PCoA analysis (MASH distance) 
### 4. Assembly-based analysis 
#### Full-assembly followed by classification 
#### Sub-assembly using classified virus reads 

### 6. Subtyping and variants calling 
