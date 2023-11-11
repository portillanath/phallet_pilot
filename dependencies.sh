#!/bin/bash

workdir="./enviroments"
cd "$workdir" || exit

# Print the current working directory
pwd

# Array of YAML files

yaml_files=("taxa_curation.yaml" "blast_feed.yaml" "ANI.yaml" "wraggling_metrics.yaml")

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

# It is necesary to install the C library MbedTLS 

# Function to download and install BLAST+ on Linux
install_blast_linux() {
    echo "Downloading and installing BLAST+ on Linux..."
    wget https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.12.0+-x64-linux.tar.gz
    tar -zxvf ncbi-blast-2.12.0+-x64-linux.tar.gz
    export PATH=$PATH:$(pwd)/ncbi-blast-2.12.0+/bin
    echo "BLAST+ installed successfully on Linux."
}

# Function to download and install BLAST+ on macOS
install_blast_macos() {
    echo "Downloading and installing BLAST+ on macOS..."
    curl -O https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.12.0+-universal-macosx.tar.gz
    tar -zxvf ncbi-blast-2.12.0+-universal-macosx.tar.gz
    export PATH=$PATH:$(pwd)/ncbi-blast-2.12.0+/bin
    echo "BLAST+ installed successfully on macOS."
}

# Function to install other dependencies
install_other_dependencies() {
    # Add commands to install other dependencies
    # For example: Run PowerShell commands to install software/packages
    echo "Installing other dependencies..."
}

# Main script
echo "Installing dependencies for your project..."

# Detect operating system
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    install_blast_linux
    install_other_dependencies
elif [[ "$OSTYPE" == "darwin"* ]]; then
    install_blast_macos
    install_other_dependencies
else
    echo "Unsupported operating system."
fi

echo "All dependencies installed successfully."



