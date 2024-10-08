#!/bin/bash
module load slurm
module load oracle_jdk
module load R
module load bioconductor

#Store command to run the .jar executable file in a variable called MIGEC, feel free to change memory allocation by changing Xmx___G
MIGEC="java -Xmx300G -jar migec-1.2.9.jar"

#Filter out erreneous CDR3 sequences produced due to sequencing or PCR errors. 
#Parameters -c and -s used to include non canonical CDR3s (do not start with C residue) and filter out CDR3s detected by single MIGs, respectively. Output folder: 'cdrfinal'
sbatch --partition=highmem --mem=350G --cpus-per-task=40 --wrap="$MIGEC FilterCdrBlastResultsBatch -c -s cdrblast/ cdrfinal/"
