#!/bin/bash

# Define variables
workdir=~/phallet
source="$workdir/Taxa_Selected"
output="$workdir/Blast_Feed"
identity_threshold="50"
blast_database="NCBI,RefSeq"

source activate dependencies

# Check if required commands are available
if ! command -v blastn &> /dev/null; then
    echo "blastn command not found. Please make sure BLAST is installed and in your PATH."
    exit 1
fi

# Parse command-line arguments
while getopts "p:d:" option; do
    case $option in
        p) # Handle the -p flag with an argument
            identity_threshold=${OPTARG}
            ;;
        d) # Handle the -d flag with an argument
            blast_database=${OPTARG}
            ;;
    esac
done

# Create output directory if it doesn't exist
mkdir -p "$output"

# Loop to process FASTA files in each subdirectory
for subdir in "$source"/*/; do
    if [[ -d "$subdir" ]]; then
        echo "Processing files in the directory: $(basename "$subdir")"
        genus="$(basename "$subdir")"
        echo "$genus"
        output_folder="$output/$genus"
        echo "$output_folder"
        mkdir -p "$output_folder"

        fasta_files=("$subdir"*.fasta)
        for fastafile in "${fasta_files[@]}"; do
            blast_result_file="${fastafile%.fasta}_blast_result.xml"
            blastn -query "$fastafile" -db nt -remote -out "$blast_result_file"
            echo "blast it is processing"
            accession="$(basename "$fastafile" .fasta)"
            sequence_output_file="$output_folder/$accession.fasta"
        done
    fi
done
