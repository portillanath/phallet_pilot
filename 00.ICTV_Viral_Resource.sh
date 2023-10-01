#!/bin/bash

# Conda Environment Creation
conda create -n crocrontab -c conda-forge crontab

# Activate Conda Environment
conda activate crocrontab

# Copy Personal Bashrc
nano ~/.bashrc

# Create a new bashrc to Path the Conda Environment
nano ~/.bashrc_conda

# Content for ~/.bashrc_conda
echo 'export CONDA_HOME="/path/to/anaconda3_install"' >> ~/.bashrc_conda
echo 'export CARGO_HOME="$HOME/.cargo"' >> ~/.bashrc_conda
echo 'export PATH="$CONDA_HOME/bin:$CARGO_HOME/bin:$PATH"' >> ~/.bashrc_conda
source ~/.bashrc_conda

#Create a Virus Metadata Resource
mkdir -p Virus_Metadata_Resource 

# After this, a new crontab job is made
crontab -e 

# Content for Crontab
echo 'SHELL=/bin/bash' > crontab_script
echo 'BASH_ENV=~/.bashrc_conda' >> crontab_script
30 12 * * * wget https://ictv.global/vmr/current > ./Virus_Metadata_Resource | rm `ls -t | awk 'NR>1'`
crontab crontab_script

# Check Crontab Status
crontab -l

