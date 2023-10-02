#!/bin/bash

# Get the path to Anaconda or Miniconda from the command line
if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/anaconda"
    exit 1
fi
conda_path="$1"

# Initialize conda for bash
eval "$("$conda_path/bin/" 'shell.bash' 'hook' 2> /dev/null)"

# Specify a path where you have write permissions
conda_env_path="${conda_path}"
echo "${conda_env_path}"

# First step is to install crontab as a conda environment
"$conda_path/bin/conda" create -y -n crocrontab
source activate "${conda_path}/envs/crocrontab"

# Installation through bioconda
"$conda_path/bin/conda" install -y -c conda-forge crontab

# Create the folder for storing ICTV Metadata
mkdir -p ./Virus_Metadata_Resource

#Create a temporary script file
echo "#!/bin/bash"> mycron_script
echo "cd ${PWD}/Virus_Metadata_Resource">> mycron_script
echo "wget https://ictv.global/vmr/current" >> mycron_script

#Make executable the script
chmod +x mycron_script

# After this, a new crontab job is made
export VISUAL=echo; crontab -e > mycron

echo "SHELL=/bin/bash">> mycron
echo "BASH_ENV='${HOME}/.bashrc_conda'" >> mycron
echo "0 12 * * * ${PWD}/mycron_script" >> mycron

#Install the crontab update
crontab mycron

#Clean temporary files
rm mycron mycron_script

# To check the status
crontab -l


