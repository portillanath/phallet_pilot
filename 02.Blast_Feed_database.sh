#!/bin/bash

#Date:11/11/2023
#This script will run blastn for each fasta file in the Taxa_Selected directory
#This is an approach for the blast feed database

# Set default values
identity_threshold=50
default_databases=("NCBI" "ReqSeq")
source_directory="./Taxa_Selected"
output_directory="./Blast_Feed"

# Parse command-line arguments
while getopts "p:d:" opt; do
  case $opt in
    p)
      identity_threshold=$OPTARG
      ;;
    d)
      IFS=' ' read -ra blast_databases <<< "$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# If blast_databases is not set, use default_databases
if [ ${#blast_databases[@]} -eq 0 ]; then
  blast_databases=("${default_databases[@]}")
fi

# Create output directory
mkdir -p "$output_directory"

# Function to run BLAST for a given fasta file and database
run_blast() {
  local fasta_file=$1
  local output_folder=$2
  local blast_databases=("${@:3}")

  for blast_database in "${blast_databases[@]}"; do
    echo "Running BLAST for: $fasta_file on database: $blast_database"
  
    blast_result_file="$output_folder/$(basename "$fasta_file" .fasta)_${blast_database}_blast_result.xml"
    blastn_cmd="blastn -query $fasta_file -remote -db $blast_database -task blastn -outfmt 5 -out $blast_result_file"

    if ! $blastn_cmd; then
      echo "Error running BLAST for: $fasta_file on database: $blast_database"
      exit 1
    fi

    echo "Copying BLAST result to: $output_folder"
    cp "$blast_result_file" "$output_folder"
    echo "Blast result obtained for: $(basename "$fasta_file") on database: $blast_database"
  done
}

# Function to process each fasta file
process_file() {
  local fasta_file=$1
  local output_folder=$2

  for blast_database in "${blast_databases[@]}"; do
    run_blast "$fasta_file" "$output_folder" "${blast_databases[@]}"
  done

  # Extract accession from the fasta file name
  accession="$(basename "$fasta_file" .fasta)"
  sequence_output_file="$output_folder/$accession.fasta"
  fasta_output_file="$output_folder/$(basename "$fasta_file")"

  echo "Downloading sequence from NCBI: $accession"
  download_ncbi_sequence "$accession" "$sequence_output_file"
  download_refseq_sequence "$accession" "$sequence_output_file"

  # Copy the original FASTA file to the output folder
  echo "Copying original FASTA file to: $fasta_output_file"
  cp "$fasta_file" "$fasta_output_file"
}

#Get subdirectories in the source directory
subdirs=$(find "$source_directory" -type d)

# Process fasta files in each subdirectory
for subdir in $subdirs; do
  echo "Processing files in $(basename "$subdir")"
  genus_name=$(basename "$subdir")
  output_folder="$output_directory/$genus_name"
  mkdir -p "$output_folder"

  fasta_files=$(find "$subdir" -name "*.fasta")

  if [ -n "$fasta_files" ]; then
    for fasta_file in $fasta_files; do
      process_file "$fasta_file" "$output_folder"

      # Check if there is a download after the blast inside the Taxa_Selected subdir
      download_file="$subdir/DownloadedFile.fasta"
      if [ -f "$download_file" ]; then
        echo "Copying download file to: $output_folder"
        cp "$download_file" "$output_folder"
      fi
    done

    # Corrected placement of blast_result_files
    blast_result_files=$(find "$output_folder" -name "*_blast_result.xml")

    for blast_result_file in $blast_result_files; do
      new_filename="$(basename "$blast_result_file" _blast_result.xml)_corrected.xml"
      mv "$blast_result_file" "$output_folder/$new_filename"
    done

  else
    echo "No fasta files found in $(basename "$subdir")"
  fi
done
