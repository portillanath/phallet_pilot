#!/bin/bash
#Dependencies Installation
#All changes are save now, but not commited
#CH
workdir="./enviroments"
cd "$workdir" || exit

# Print the current working directory
pwd

# Get the path to the conda executable
CONDA_PATH=$(which conda)
echo "Conda path: $CONDA_PATH"

# Check if conda is installed
if [ -z "$CONDA_PATH" ]; then
    echo "Conda is not installed or not in the system PATH."
    exit 1
fi

# Set the default environment manager
DEFAULT_MANAGER="conda"

# Add the conda command to the .bashrc file
echo "alias conda='$CONDA_PATH'" >> ~/.bashrc

# Set the default environment manager in the .bashrc file
echo "export CONDA_DEFAULT_ENV_MANAGER=$DEFAULT_MANAGER" >> ~/.bashrc

# Activate the changes in the current shell session
source ~/.bashrc

# Array of YAML files

yaml_files=("taxa_curation.yaml" "blast_feed.yaml" "ANI.yaml" "wraggling_metrics.yaml" "mash.yaml")

# Loop through YAML files and create Conda environments
for file in "${yaml_files[@]}"; do
  # Check if the file exists
  if [ -f "$file" ]; then
    # Extract environment name from YAML file using basename
    env_name=$(basename "$file" .yaml)
    # Print information
    echo "Creating Conda environment '$env_name' from '$file'"
    # Create Conda environment
    conda env create --name "$env_name" --file "$file"
  else
    echo "File not found: $file"
  fi
done


