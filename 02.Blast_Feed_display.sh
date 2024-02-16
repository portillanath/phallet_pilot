#!/bin/bash 

workdir=~/phallet
cd $workdir 

identity_threshold=50
blast_database="NCBI,RefSeq"

# Check if required commands are available
if ! command -v blastn &> /dev/null; then
    echo "blastn command not found. Please make sure BLAST is installed and in your PATH."
    exit 1
fi

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

#="$identity_threshold" -d "$blast_database"

source="~/phallet/Taxa_Selected"
output="~/phallet/Blast_Feed"
mkdir -p output 

#Function for retrive sequences from NCBI



#Function for display blast 

#Loop for processes fasta files in each subdirdirectory
for subdir in "$source"/*/;do
    if [[ -d "$subidr"]];then 
        echo "processing files in the directory: $(basename "$subidr")"
        genus="$(basename "$subdir")"
        output_folder="$output/$genus"
        mkdir -p "$output_folder"

        fasta_files=("$subdir"*.fasta)
        for fastafile in "${fasta_files[@]}"; do
            processes_file "$fastafile"
        done