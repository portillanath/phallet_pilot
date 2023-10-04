#!/bin/bash
# Author: Nathalia Portilla
# Script Name: 01.Taxa_Curation_Level.sh

#SBATCH --job-name=Taxa_Selected
#SBATCH -p medium
#SBATCH -N 1
#SBATCH -n 4
#SBATCH --cpus-per-task=1
#SBATCH --mem=100G
#SBATCH --time=2-00:00:00
#SBATCH --mail-user=na.portilla10@uniandes.edu.co
#SBATCH --mail-type=ALL
#SBATCH -o Taxa_Curation_Level_job.o%j

workdir=~/phallet
cd $workdir 

#Create a directory for taxa selected

mkdir -p Taxa_Selected

#Create a new enviroment from a yaml file 
#conda run -n base bash -c "echo \${CONDA_PREFIX}" > conda_path
conda env create -f r_env.yml
#echo "${conda_path}/envs/my_r_env"
source activate r_env

#Run R script for the genus provided as arguments 

for genus_name in "$@";do
Rscript 01.Taxa_Curation_Level.r $genus_name
done

conda deactivate
