#!/bin/bash
data_default=~/phallet/test_genus.txt
#Run phallet steps 
time bash 00.ICTV_Metadata_Resource.sh
time bash 01.Taxa_Curation_Level.sh $data_default
time bash 02.Blast_Feed.sh 
time bash 03.Merge_blast.sh 
time bash 04.Mash_Metrics.sh
time bash 05.ANI_Metrics.sh 
time bash 06.wraggling.sh
time bash 07.Graphing.sh

