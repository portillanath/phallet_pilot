library(seqinr)
library(dplyr)
library(purrr)
library(fs)

# Set working directories
source_directory <- "~/phallet/Taxa_Selected"
output_directory <- "~/phallet/Blast_Feed"

setwd(source_directory)  # Set the working directory to the source directory

# Get list of subdirectories
subdirs <- list.dirs(source_directory, full.names = FALSE, recursive = FALSE)

# Check for subdirectories with the "feed" extension in the output directory
all_subdirs <- list.dirs(output_directory, full.names = TRUE, recursive = TRUE)
subdirs_feed <- grep("_feed$", all_subdirs, value = TRUE)

#Copy subdirectories to output directory if they are not already present
   for (subdir_feed in subdirs_feed) {
      if (!dir_exists(subdir_feed)) {
      dir_copy(source_directory, subdirs_feed)
      print(paste("Copied:", source_directory, "->", subdirs_feed))
     } 
    else {
    print(paste("Skipped (already exists):", source_directory, "->", subdirs_feed))
  }
}







