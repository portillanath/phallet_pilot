#!/usr/bin/env python
# coding:utf-8 

#In [5]:

import os
import time 
import pandas as pd
from Bio import Entrez
from Bio import NCBIWWW
import argsparse
from Bio import SeqIO


 #List of possible arguments
  identity_threshold = sys.argv[1]
  blast_database = sys.argv[2]  
   
  #Check if the command lines argument is provided  
  if len (sys.argv)==2:
    print("Please provide p- porcentage of identity and d- name of database(s).")
    sys.exit(1)
    
  
 #Define the argument parser
parser=argparse.ArgumentParser()
    
  #Get the command line arguments throught the parser 
  
  parser.add_argument("-p",type=float, help="Provide a number for porcentage of identity")
  parser.add_argument("-d",nargs="+", help="Provide name od database for Blast Feed")
  
  args = parser.parse_args()
  
#Create a folder for sequences retrieved from feed
ncbi_genome_actual = "./Blast_Feed
os.makedirs(Blast_Feed, exist_ok=True)

os.chdir("./Taxa_Selected")
genus_list=os.listdir(path='./Taxa_Selected')

#Now we are going to loop each fasta sequence per genus to display BLAST using the porcentage indentity display
for genus in genus_list:
  for filefasta in glob.glob("*.fasta", recursive=False):
    with open(os.path.join(os.getcwd(),filefasta),'r') as fasta:
    sequence_data=open(fasta).read()
        for database in args.database:
        result_handle=NCBIWWW.qblast("blastn",database=database ,sequence_data,perc_ident=identity_threshold)
    blast_result_filename=f"blast_result_{genus}_{filefasta}_{database}.xml"
    with open(blast_result_filename,"w") as blast_result:
      blast_result.write(result_handle.read())
    result_handle.close()
    
   

# Function to download sequences from NCBI
download_ncbi_sequence <- function(accession, output_file) {
  url <- paste("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=", accession,
               "&rettype=fasta&retmode=text", sep = "")
  tryCatch(
    {
      download.file(url, output_file, quiet = TRUE, mode = "wb")
    },
    error = function(e) {
      if (grepl("HTTP status was '502'", conditionMessage(e))){
        cat("\nTemporary sever issue. Retrying in 60 seconds....\n")
        Sys.sleep(60)
        download_sequence(accession, output_file)
      } else {
        cat("\nError download sequence: ",accession, "\n")
        cat("Error:",conditionMessage(e),"\n")
        Sys.sleep(5)
      }
    }
  )
}

# Function to download RefSeq sequences from NCBI by accession
download_refseq_sequence <- function(accession, output_file) {
  url <- paste("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=", accession,
               "&rettype=fasta&retmode=text", sep = "")
  tryCatch(
    {
      download.file(url, output_file, quiet = TRUE, mode = "wb")
    },
    error = function(e) {
      if (grepl("HTTP status was '502'", conditionMessage(e))){
        cat("\nTemporary server issue. Retrying in 60 seconds....\n")
        Sys.sleep(60)
        download_refseq_sequence(accession, output_file)
      } else {
        cat("\nError download RefSeq sequence: ", accession, "\n")
        cat("Error:", conditionMessage(e), "\n")
        Sys.sleep(5)
      }
    }
  )
}

# Process each fasta file
process_file <- function(fasta_file, output_folder) {

  blast_result_file <- paste0(tools::file_path_sans_ext(fasta_file), "_blast_result.xml")
  blastn_cmd <- paste("blastn -query", shQuote(fasta_file), "-db", shQuote(db_path),
                      "-outfmt 5 -out", shQuote(blast_result_file))
  system(blastn_cmd)

  file.copy(blast_result_file, output_folder)
  cat("Blast result obtained for:", basename(subdir), "\n")
  
  # Extract accession from the fasta file name
  accession <- sub(".*\\/(\\w+)\\.fasta$","\\1",fasta_file)
  sequence_output_file <- file.path(output_folder, paste(accession, ".fasta", sep = ""))
  fasta_output_file <- file.path(output_folder, basename(fasta_file))

  # Download the sequence from NCBI and save as FASTA
  download_ncbi_sequence(accession, sequence_output_file)
  download_refseq_sequence(accession,sequence_output_file)

  # Copy the original FASTA file to the output folder 
  fasta_output_file <-file.path(output_folder, basename(fasta_file))
  file.copy(fasta_file, fasta_output_file)

}

# Get subdirectories in the source directory
subdirs <- dir(source_directory, full.names = TRUE, recursive = FALSE)

# Process fasta files in each subdirectory
for (subdir in subdirs) {

  cat("Processing files in", basename(subdir), "\n")
  genus_name <- basename(subdir) 
  output_folder <- file.path(output_directory, paste(genus_name, "_feed", sep = ""))
  dir.create(output_folder, recursive = TRUE, showWarnings = FALSE)
  
  fasta_files <- list.files(subdir, pattern = "\\.fasta$", full.names = TRUE, recursive = TRUE)

  if (length(fasta_files) > 0) {

    for (fasta_file in fasta_files){
      process_file(fasta_file, output_folder)
    }

    # Corrected placement of blast_result_files
    blast_result_files <- list.files(output_folder, pattern = "_blast_result.xml$", full.names = TRUE)

    for (blast_result_file in blast_result_files){
      new_filename <- paste0(tools::file_path_sans_ext(blast_result_file), "_corrected.xml")
      file.rename(blast_result_file, new_filename)
    }

  } else {
    cat("No fasta files found in", basename(subdir), "\n")
  }
}

if __name__=="main":
  import sys
   
 