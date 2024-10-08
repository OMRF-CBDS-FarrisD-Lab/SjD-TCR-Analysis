#!/bin/bash
module load slurm
module load oracle_jdk
module load R
module load bioconductor
module load ncbi_blast+

#Store command to run the .jar executable file in a variable called MIGEC, feel free to change memory allocation by changing Xmx___G
MIGEC="java -Xmx300G -jar migec-1.2.9.jar"

#Extract CDR3 sequences and V/J information from TCR beta chain (all alleles). QC threshold for raw and assembled data chosen after optimization. Output folder: 'cdrblast'
#This routine is the most memory-intensive step and takes a long time to complete, hence memory and compute nodes allocated are very high.  
sbatch --partition=highmem --mem=480G --cpus-per-task=60 --wrap="$MIGEC CdrBlastBatch --default-mask 0:1 --default-quality-threshold 20,25 --all-alleles -R TRB checkout/ assemble/ cdrblast/"
