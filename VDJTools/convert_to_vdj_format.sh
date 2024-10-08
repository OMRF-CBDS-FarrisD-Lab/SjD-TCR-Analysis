#!/bin/bash
module load slurm
module load R
module load oracle_jdk
module load bioconductor

#Store command to run the .jar executable file in a variable called VDJT, feel free to change memory allocation by changing Xmx___G
#Filename (vdjtools-1.2.1.jar) should be the absolute filepath (e.g. users/username/parent_directory/vdjtools-1.2.1/file.jar) or relative to the current directory (e.g. vdjtools-1.2.1/file.jar) 
VDJT="java -Xmx250G -jar vdjtools-1.2.1.jar"

#We use sbatch command to submit the job to slurm workload manager, command for the 'convert' routine is wrapped within double quotes here. All vdjtools routines have been wrapped and executed this way.
#Parameters are set to convert the format of a list of samples in the metadata file from migec to that of vdjtools. 
#Parameter -S is used to specify the format to convert from, -m specifies the metadata file (sample - vdj_metadata.txt).
#Detailed instructions at: https://vdjtools-doc.readthedocs.io/en/master/input.html   
sbatch --mem=256G --cpus-per-task=16 --wrap="$VDJT Convert -S migec -m vdj_metadata.txt vdj_input/" 
