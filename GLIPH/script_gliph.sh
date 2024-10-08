#!/bin/bash
module load slurm

#We run the algorithm on an HPC environment using sbatch command and submit it to the slurm workload manager. 
#Config file (conf.cfg) contains parameter settings and filenames of all reference files and input files, it should be in the same directory as all other input files
#The command to execute GLIPH2 is wrapped within double quotes here. If not running on a compute cluster, see http://50.255.35.37:8080/ for more information. 
#Additionally, GLIPH2 can be run on a web interface for a maximum of upto 250,000 CDR3s (http://50.255.35.37:8080/project) 
#Linux executable (irtools.centos) available at http://50.255.35.37:8080/downloads/irtools.centos 
#Further details on interpreting settings and parameters can be found at (https://github.com/immunoengineer/gliph/blob/master/README.md) 
sbatch --partition=highmem --mem=300G --partition=highmem --cpus-per-task=48 --wrap="./irtools.centos -c conf.cfg"


