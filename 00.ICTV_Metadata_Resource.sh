#!/bin/bash

#pip install xlsx2csv

# Create the folder for storing ICTV Metadata
mkdir -p ./Virus_Metadata_Resource

#Delete existing "current" file 
if [ -f "./Virus_Metadata_Resource/current" ]; then
    rm ./Virus_Metadata_Resource/current
fi

#Download latest current file 
cd ./Virus_Metadata_Resource
wget https://ictv.global/vmr/current
xlsx2csv current VMR.csv

