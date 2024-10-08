#!/bin/bash
module load slurm
module load R
module load oracle_jdk
module load bioconductor

#Store command to run the .jar executable file in a variable called VDJT, feel free to change memory allocation by changing Xmx___G
VDJT="java -Xmx200G -jar vdjtools-1.2.1/vdjtools-1.2.1.jar"

#Parameters are set to calculate diversity of CDR3 beta amino acid sequences (-i aa) using a metadata file for inputs (sample - metadata.txt) 
sbatch --mem=200G --cpus-per-task=24 --wrap="$VDJT CalcDiversityStats -i aa -m metadata.txt DiversityStats/"
