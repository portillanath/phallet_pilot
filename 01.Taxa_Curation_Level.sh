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

conda create -n dependencies
conda activate dependencies
conda install pandas
conda install -c "conda-forge/label/cf201901" biopython

for genus_name in "$@";do
python3 01.Taxa_Curation_Level.py $genus_name
done
