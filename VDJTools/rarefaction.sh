#!/bin/bash
module load slurm
module load R
module load oracle_jdk
module load bioconductor

#Store command to run the .jar executable file in a variable called VDJT
VDJT="java -Xmx200G -jar ../vdjtools-1.2.1.jar"


#Parameters are set to plot rarefaction curves for list of samples in the metadata file (metadata.txt)
#Parameter -f specifies plotting factor (e.g. under the column 'Status', enter 'case' for patients and 'control' for healthy subjects in the metadata file)    
sbatch --mem=200G --cpus-per-task=16 --wrap="$VDJT RarefactionPlot -f Status -m metadata.txt RarefactionPlot/"
