#!/bin/bash

# Initialize conda for bash
eval "$(conda 'shell.bash' 'hook' 2> /dev/null)"

# Specify a path where you have write permissions
conda_env_path="${CONDA_PREFIX}"
echo "${conda_env_path}"

# First step is to install crontab as a conda environment
conda create -y -n crocrontab 
conda activate crocrontab

# Installation through bioconda
conda install -y -c conda-forge crontab
pip install xlsx2csv

# Create the folder for storing ICTV Metadata
mkdir -p ./Virus_Metadata_Resource

#Delete existing "current" file 
if [ -f "./Virus_Metadata_Resource/current" ]; then
    rm ./Virus_Metadata_Resource/current
fi

#Download latest current file 
cd ./Virus_Metadata_Resource
wget https://ictv.global/vmr/current
xlsx2csv current VMR.csv

# After this, a new crontab job is made
echo "SHELL=/bin/bash"> mycron
echo "BASH_ENV='${HOME}/.bashrc_conda'" >> mycron
echo "0 12 * * * ${PWD}/mycron_script" >> mycron

cat mycron

#Install the crontab update
crontab mycron

#Clean temporary files
rm mycron

# To check the status
crontab -l