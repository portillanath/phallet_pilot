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

workdir=
cd $workdir 

#Create a directory for taxa selected

mkdir -p Taxa_Selected

source activate /hpcfs/home/ciencias_biologicas/na.portilla10/anaconda3_install/envs/my_r_env

#Run R script for each genus 

for genus_name in "$@";do
Rscript B.Taxa_curation_resource.r $genus_name
done

conda deactivate
