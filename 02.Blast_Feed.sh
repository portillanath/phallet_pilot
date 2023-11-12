#!/bin/bash

workdir=~/phallet
cd $workdir 

source ~/miniconda3/bin/activate blast_feed

identity_threshold=50
blast_database="NCBI,RefSeq"

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

Rscript 02.Blast_Feed.r -p "$identity_threshold" -d "$blast_database" > blast_feed.log 2>&1

cat blast_feed.log
