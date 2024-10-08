#!/bin/bash
module load slurm
module load oracle_jdk
module load R
module load bioconductor

#Store command to run the .jar executable file in a variable called MIGEC, feel free to change memory allocation by changing Xmx___G
MIGEC="java -Xmx200G -jar migec-1.2.9.jar"

#Perform a batch assembly of FASTQ files generated by the checkout routine. All assembly parameters (e.g. overseq threshold specified by the option --force-overseq) are chosen as per Histogram output. Output folder: 'assemble'  
sbatch --partition=highmem --mem=200G --cpus-per-task=50 --wrap="$MIGEC AssembleBatch --default-mask 0:1 --force-overseq 5 --force-collision-filter checkout/ histogram/ assemble/"