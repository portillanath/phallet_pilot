# Load required libraries
library(seqinr)
library("xml2")

#Read command-line arguments 
args<-commandArgs(trailingOnly=TRUE)

#Check if there are a incomplete command line 
if(length(args)<2){
  stop("Incomplete command line. Please provide the path to the BLAST result file and the path to the FASTA file.")
}

#Parse the command line arguments 
identity_threshold<-as.numeric(args[1])
blast_database<-args[2]

# Set the directory containing subdirectories with fasta files and create a new directory for the Feed
source_directory <- "~/phallet/Taxa_Selected"
output_directory <- "~/phallet"
output_directory <- file.path(output_directory, "Blast_Feed")
dir.create(output_directory, recursive = TRUE, showWarnings = FALSE)

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
  blastn_cmd <- paste("blastn -query", shQuote(fasta_file), "-remote -db", shQuote(blast_database),
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
  output_folder <- file.path(output_directory, paste(genus_name, sep = ""))
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