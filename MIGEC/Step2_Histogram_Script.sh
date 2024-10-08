#!/bin/bash
module load slurm
module load oracle_jdk
module load R
module load bioconductor

#Store command to run the .jar executable file in a variable called MIGEC, feel free to change memory allocation by changing Xmx___G
MIGEC="java -Xmx256G -jar migec-1.2.9.jar"

#Run the histogram routine (wrapped here within quotes) to determine MIG size distribution and the appropriate minimum overseq threshold for the next step (assembly). Look for estimates.txt in the output folder 'histogram'
#The fastq.gz files (n = 38) of PB-TCR sequences from the SRA submission (PRJNA1152703) can be downloaded into a folder named checkout and used to run the histogram routine as follows:
sbatch --partition=highmem --cpus-per-task=50 --mem=380G --wrap="$MIGEC Histogram checkout/ histogram/"
