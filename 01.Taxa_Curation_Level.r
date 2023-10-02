#Name Script:taxa_curation.r
#Author: Nathalia Portilla
#Date: 29/04/2023

library("fuzzyjoin")
library("openxlsx")
library(dplyr)
library(purrr)
library(tidyr)
library(rentrez)

#Subset from the ICTV by type of host, and completeness of genome 

retrive_genomes<-function (genera_list){

#Read the genus or buch of genera to run 

ICTVassignation<-read.csv("./Virus_Metadata_Resource/VMR.csv",sheet=1)
colnames(ICTVassignation)<-c("Sort","Isolate_Sort","Realm","Subrealm","Kingdom","Subkingdom","Phylum","Subphylum","Class","Subclass","Order","Suborder","Family","Subfamily","Genus",
"Subgenus","Species","Exemplar_or_additional_isolate","Virus_name(s)","Virus_name_abbreviation(s)","Virus_isolate_designation","Virus_GENBANK_accession","Virus_REFSEQ_accession",
"Genome_coverage","Genome_composition","Host_source")
ICTVassignation <- subset(ICTVassignation, Host_source=="archaea" | Host_source=="bacteria")
ICTVassignation <- subset(ICTVassignation, Genome_coverage=="Complete genome"| Genome_coverage=="Complete coding genome")
write.csv(ICTVassignation, file ="./ICTV_assignation_Complete.csv", row.names = FALSE)

#Extract accessions for search on NCBI
accessions<-unique(ICTVassignation$Virus_GENBANK_accession)
print(paste0("The number of number of phages with complete genome for all ICTV database is:", length(accessions)))

#Creates a folder for storage the selected taxas 
ncbi_genome_actual<-"/hpcfs/home/ciencias_biologicas/na.portilla10/Source_PhageClouds/Taxa_Selected"
dir.create(ncbi_genome_actual, recursive=TRUE, showWarnings=FALSE)

for (genus in genus_list){

#Filter the ICTV assignation for the current genus 
genus_data<-subset(ICTVassignation,Genus==genus)

#Check if there is any records found for the genus 

if(nrow(genus_data)==0){
   cat("No records found for the genus:",genus,"\n")
   next
}

#Create a subfolder for the genus if it doesn't exist
genus_folder<-file.path(ncbi_genome_actual,genus)

if(!dir.exists(genus_folder)){
  dir.create(genus_folder,recursive=TRUE,showWarnings=TRUE)
}

#Iterate over accessions for the current genus
for (accession in seq_along(genus_data$Virus_GENBANK_accession)){
    file_name<-paste0(genus_data$Virus_GENBANK_accession[accession],".fasta")
    file_path<-file.path(genus_folder,file_name)

    while(TRUE){

    seq<-tryCatch(
        {
            entrez_fetch(db="nucleotide",id=genus_data$Virus_GENBANK_accession[accession], rettype="fasta", retmode="text")
        },

        error=function(e){
            cat("Error:",conditionMessage(e),"\n")
            Sys.sleep(5)
            return("")
          }
        )
    #Check retrivied sequences

    if(length(seq)>0){
        cat(seq,file=file_path)
        cat("Downloaded",file_name,"\n")
        break
      }

    #Check if the files was created
    if(file.exists(file_path)){
        cat("New FASTA file created:",file_path,"\n")
       }
      }
     }
    }
   
   #Check if the command line arguments are provided

   if(length(commandArgs(trailingOnly=TRUE))==0){
   cat("Please provide either a CSV file path with the list of genus or type space separate the genus names")
   quit(status=1)
   }

   #Get the command-line arguments
   input_argument<-commandArgs(trailingOnly=TRUE)[1]

    #Check if the input is a CSV file or a list of genera

    if(file.exists(input_argument)){

    #Read the CSV file
       genera_csv<-read.csv(input_argument)
       genera_list_csv<-genera_csv$Genus
       retrive_genomes(genera_list_csv)

    }else{
    #Split the input by space
    genera_space<-input_argument
    genera_list_space<-strsplit(genera_space," ")[[1]]
    retrive_genomes(genera_list_space)
    }

}

