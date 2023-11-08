#!/bin/bash
#Author:Nathalia Portilla
#name script:wraggling.sh
#SBATCH -o Graphing_job.o%j

workdir=~/phallet
cd $workdir 

source ~/miniconda3/bin/activate wraggling_metrics

kmersy=(15,17,20,21,24)
kmersx=(12,11,10,9,8)
my="mash"
mx="ani"

while getopts "mx:kmersx:my:kmersy" option; do
    case $option in
        mx) #Handle the -mx flag with an argument
        mx=${OPTARG}
        ;;
        kmersx) #Handle the -kmersx flag with an argument
        kmersx=${OPTARG} 
        ;;
        my) #Handle the -my flag with an argument
        my=${OPTARG}
        ;;
        kmersy) #Handle the -kmersy flag with an argument
        kmersy=${OPTARG}
        ;;
    esac
done

python3 07.Graphing.py -mx "$mx" -kmersx "$kmersx" -my "$my" -kmersy "$kmersy" > Graphing.log 2>&1
cat Graphing.log

conda deactivate 