#Name Script:metrics_wraggling.r
#Author: Nathalia Portilla

library(data.table)
library(igraph)
library(reshape2)
library(dplyr)
library(stringr)
library(readr)
library(fs)

#Storage every output in a new folder per genus that exists in Blast_Feed
source<- "~/phallet/Blast_Feed"
subdirectories <- list.dirs(source, recursive = FALSE)
workdir <- "~/phallet/Metrics_Results"

#This for moving all outputs to a individual folders
for (genus in subdirectories){
genus_name <- tail(strsplit(genus, "/")[[1]], 1)
genus_dir <-file.path(workdir,genus_name)

#Check if the directory already exists
if (!dir.exists(genus_name)){
  dir.create(genus_name)

#Move all the file in wordir that match with the genus
 files_to_move <- list.files(workdir)
  for (file in files_to_move) {
    if(grepl(genus_name,file)){
    file.rename(from = file.path(workdir, file), to = file.path(genus_dir,file))
     }                       
   }
 }
}

#Read command-line arguments 
args<-commandArgs(trailingOnly=TRUE)

#Parse the command line arguments 
mx<-args[1]
kmersx<-as.numeric(args[2])
my<-args[3]
kmersy<-as.numeric(args[4])

#Default kmers to merge 
kmersy=c(15,17,20,21,24)
kmersx=c(12,11,10,9,8)
my<-"mash"
mx<-"ani"

#Set up directories on workdir
subdirectories <- list.dirs(workdir, recursive = FALSE)

  #SEARCH FOR OUTPUT FILES
  #Recover possible algorithms for each metric of the pairwise correlation 
  
  #Cases for metrics selected avaible
 if (mx == "mash") {
  tool_mx <- c("mash", "sourmash")
} else if (mx == "ani") {
  tool_mx <- c("fastani", "skani")
} else if (mx == "aai") {
  tool_mx <- c("comparem")
} else if (mx == "viridic") {
  tool_mx <- c("viridic")
} else if (mx == "vcontact2") {
  tool_mx <- c("vcontact2")
} else {
  stop("Invalid metric selected")
}

  #Cases for metrics selected on Y
if (my == "mash") {
  tool_my <- c("mash", "sourmash")
} else if (my == "ani") {
  tool_my <- c("fastani", "skani")
} else if (my == "aai") {
  tool_my <- c("comparem")
} else if (my == "viridic") {
  tool_my <- c("viridic")
} else if (my == "vcontact2") {
  tool_my <- c("vcontact2")
} else {
  stop("Invalid metric selected")
}

metrics<-c(mx,my)
print(metrics)
#This make the parsing for the correspondent metric
fastani_results <- data.table()
skani_results <- data.table()

for (subdir in subdirectories) {
  setwd(file.path(subdir))
  subdir_name<-basename(subdir)

for(m in metrics){

  if(m==mx){
  tool_list<-c(tool_mx)
  kmers<-kmersx}
  if(m==my){
  tool_list<-c(tool_my)
  kmers<-kmersy}

for (tool in tool_list){ 
print(tool_list)

## In case of having fastani metrics 

if(tool=="fastani"){
  print("Merge the fastani distance data")
  files_fastani <- list.files(pattern = "fastani.*")

  for (file in files_fastani) {
    k <- str_extract(file, "(?<=_)[0-9]+$")
    k <- as.integer(k)
    print(k)
    
    if (k %in% kmers){
      if (file.size(file) == 0) {
      next  # Continue with the next iteration (next kmer or next directory)
      }
      data_fastani <- fread(file, header = FALSE)
      if(ncol(data_fastani)<2){
      next  # Continue with the next iteration (next kmer or next directory)
      }
      data_fastani<-data_fastani[,-c(4:5)]
      data_fastani<-mutate(data_fastani,kmer_ani=k)
      colnames(data_fastani) <- c("GenomeA", "GenomeB", "ANI", "kmer_ani")
      data_fastani$GenomeA <- str_replace(data_fastani$GenomeA, "^.*/", "")
      data_fastani$GenomeB <- str_replace(data_fastani$GenomeB, "^.*/", "")
      data_fastani$GenomeA <- sub("\\..*", "", data_fastani$GenomeA)
      data_fastani$GenomeB <- sub("\\..*", "", data_fastani$GenomeB)
      fastani_results <- rbind(fastani_results,data_fastani)
    }
   }  
 }

  fastani_results<-mutate(fastani_results,algorithm_ani="fastani")
  fwrite(fastani_results, "fastani_results.csv")

  if(file.exists("fastani_results.csv")){
  print("The CSV fastani file was created")
  } else {
  print("The CSV fastani file was not created")
  }

print("Merge the skani distance data")
 
if(tool=="skani"){
  files_skani <- list.files(pattern = "skani.*")
  for(file in files_skani){
  data_skani<- read.table(file,header=FALSE,sep= "",strip.white=TRUE,
               col.names=c("Ref_file","Query_file","ANI","Align_fraction_ref","Align_fraction_query","Ref_name","Query_name"))
  colnames(data_skani)<-c("GenomeA","GenomeB","ANI")
  data_skani$GenomeA <-str_replace(data_skani$GenomeA, "^.*/", "")
  data_skani$GenomeB <-str_replace(data_skani$GenomeB, "^.*/", "")
  data_skani$GenomeA <- sub("\\..*", "", data_skani$GenomeA)
  data_skani$GenomeB <- sub("\\..*", "", data_skani$GenomeB)
  skani_results<-rbind(skani_results,data_skani)
  print(head(data_skani))
  }
}

  skani_results<-mutate(skani_results,kmer_ani="static",algorithm_ani="skani")
  fwrite(skani_results,"skani_results.csv")

  if(file.exists("skani_results.csv")){
  print("The CSV skani file was created")
  } else {
  print("The CSV skani file was not created")
  }

  # Merge ANI metric data
  ani_metric_results <- rbindlist(list(fastani_results,skani_results))
  # Write the merged results to a file
  fwrite(ani_metric_results, "ani_metric_results.csv")
}
}
}
  

   

