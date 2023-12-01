#!/bin/bash
data_default=~/phallet/test_genus.txt
#Run phallet steps 
bash 00.ICTV_Metadata_Resource.sh
bash 01.Taxa_Curation_Level.sh $data_default
bash 02.Blast_Feed.sh 
bash 03.Merge_blast.sh 
bash 04.Mash_Metrics.sh
bash 05.ANI_Metrics.sh 
bash 06.wraggling.sh
bash 07.Graphing.sh

