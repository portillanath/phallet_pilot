#!/bin/bash

workdir=~/phallet/
cd $workdir

source activate blast_feed
Rscript 03.Merge_blast.r
python3 08.Summary_Feed.py

source=~/phallet/Blast_Feed
subdirs=($(find "$source" -mindepth 1 -type d))

for subdir in "${subdirs[@]}"; do
  subdir_basename=$(basename "$subdir")
cd ${subdir}
rm *.xml
done

conda deactivate 
