#!/bin/bash
workdir="~/phallet/enviroments"
cd $workdir
#This Script is made for install all dependencies

#Install and create all conda enviroments 
conda create --name taxa_curation --file taxa_curation.yaml --no-prefix
conda create --name blast_feed --file blast_feed.yaml --no-prefix
conda create --name ANI --file ANI.yaml --no-prefix
conda create --name wraggling_metrics --file wraggling_metrics.yaml --no-prefix