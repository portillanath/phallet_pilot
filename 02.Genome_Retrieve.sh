#!/bin/bash

# Define the function to retrieve genomes
retrieve_genomes() {
    # Read the genus or bunch of genera to run
    ICTV_assignation=$(cat ./Virus_Metadata_Resource/VMR.csv | sed 's/^[ \t]*//;s/[ \t]*$//' | sed '1s/ /_/g')
    echo "$ICTV_assignation" | awk -F ',' '$22 == "archaea" || $22 == "bacteria"' | awk -F ',' '$20 == "Complete genome" || $20 == "Complete coding genome"' > ./ICTV_assignation_Complete.csv

    # Extract accessions for search on NCBI
    accessions=$(cat ./ICTV_assignation_Complete.csv | awk -F ',' '{print $19}' | sort -u)
    echo "The number of phages with complete genome for all ICTV database is: $(echo "$accessions" | wc -l)"

    # Creates a folder for storage the selected taxas
    ncbi_genome_actual="./Taxa_Selected"
    mkdir -p "$ncbi_genome_actual"

    # Iterate over genera
    for genus in "$@"
    do
        # Filter the ICTV assignation for the current genus
        genus_data=$(echo "$ICTV_assignation" | awk -F ',' -v g="$genus" '$16 == g')

        # Check if there are any records found for the genus
        if [ -z "$genus_data" ]
        then
            echo "No records found for the genus: $genus"
            continue
        fi

        # Create a subfolder for the genus if it doesn't exist
        genus_folder="$ncbi_genome_actual/$genus"
        echo "Trying to create folder: $genus_folder"
        mkdir -p "$genus_folder"

        # Iterate over accessions for the current genus
        while read -r accession
        do
            file_name="$accession.fasta"
            file_path="$genus_folder/$file_name"

            while true
            do
                seq=$(esearch -db nucleotide -query "$accession" | efetch -format fasta)
                if [ -n "$seq" ]
                then
                    echo "$seq" > "$file_path"
                    echo "Downloaded $file_name"
                    break
                else
                    echo "Error: Failed to download $file_name"
                    sleep 5
                    continue
                fi
            done

            # Check if the file was created
            if [ -f "$file_path" ]
            then
                echo "New FASTA file created: $file_path"
            fi
        done <<< "$genus_data" | awk -F ',' '{print $19}'
    done
}

# Check if the command line arguments are provided
if [ $# -eq 0 ]
then
    echo "Please provide either a CSV file path with the list of genus or type space-separated genus names"
    exit 1
fi

# Get the command-line arguments
input_argument="$1"

if [ -f "$input_argument" ]
then
    # Read the text file with genus names
    genera_list_txt=$(cat "$input_argument" | sed 's/^[ \t]*//;s/[ \t]*$//')

    if [ -z "$genera_list_txt" ]
    then
        echo "No genus names found in the provided file."
        exit 1
    fi

    # Call the function with the list of genera
    retrieve_genomes $genera_list_txt

else
    # Split the input by space
    genera_space="$input_argument"
    genera_list_space=($genera_space)

    if [ ${#genera_list_space[@]} -eq 0 ]
    then
        echo "No genus names found in the provided space-separated input."
        exit 1
    fi

    # Call the function with the list of genera
    retrieve_genomes "${genera_list_space[@]}"
fi