#!/bin/bash
#Author:Nathalia Portilla
#name script:03.NCBI_Blast_Feed.sh

#This script for download data from 
#SBATCH --job-name=Blast_Feed            #Nombre del job
#SBATCH -p medium                #Cola a usar, Default=short (Ver colas y límites en /hpcfs/shared/README/partitions.txt)
#SBATCH -N 1                            #Nodos requeridos, Default=1
#SBATCH -n 4                            #Tasks paralelos, recomendado para MPI, Default=1
#SBATCH --cpus-per-task=1               #Cores requeridos por task, recomendado para multi-thread, Default=1
#SBATCH --mem=50G      #Memoria en Mb por CPU, Default=2048
#SBATCH --time=1-00:00:00                       #Tiempo máximo de corrida, Default=2 horas
#SBATCH --mail-user=na.portilla10@uniandes.edu.co
#SBATCH --mail-type=ALL
#SBATCH -o Blast_Feed.o%j

workdir=~/phallet
cd $workdir 

module load blast
source activate dependencies
conda install pip
pip install pandas
pip install biopython

while getopts "p:d:" option; do
    case $option in
        p) #Handle the -p flag with an argument
        identity_threshold=${OPTARG}
        ;;
        d) #Handle the -d flag with an argument
        blast_database=${OPTARG} 
        ;;
    esac
done

python3 02.Blast_Feed.py -p "$identity_threshold" -d "$blast_database"


