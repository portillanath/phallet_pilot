#!/usr/bin/env python
# coding:utf-8 

#In [5]:

import os
import time 
import pandas as pd
import argparse
import getopt
import sys
from Bio import Entrez
from Bio import NCBIWWW
from Bio import SeqIO

def parsearg(argv):
  arg_identity_threshold=""
  arg_blast_database=""
  arg_help="{0} -p <identity_threshold> -d <blast_database>".format(argv[0])
  
  try:
    opts,args=getopt.getopt(argv[1:],"p:d:",["help","identity_threshold=","blast_database="])
    
  except:
    print(arg_help)
    sys.exit(2)
    
  for opt,arg in opts:
    if opt in ("-h","--help"):
      print(arg_help)
      sys.exit(2)
      
    elif opt in ("-p","--identity_threshold"):
      arg_identity_threshold=arg
      
    elif opt in ("-d","--blast_database"):
      arg_blast_database=arg
      
  print("identity_threshold",arg_identity_threshold)
  print("blast_database",arg_blast_database)

 #List of possible arguments
identity_threshold = sys.argv[1]
blast_database = sys.argv[2]  
  
#Create a folder for sequences retrieved from feed
blast_feed = "./Blast_Feed"
os.makedirs(blast_feed, exist_ok=True)

os.chdir("./Taxa_Selected")
genus_list=os.listdir(path='./Taxa_Selected')

#Now we are going to loop each fasta sequence per genus to display BLAST using the porcentage indentity display
for genus in genus_list:
    for filefasta in glob.glob("*.fasta", recursive=False):
         with open(os.path.join(os.getcwd(),filefasta),'r') as fasta:
            sequence_data=open(fasta).read()
            for database in [blast_database]:
                result_handle=NCBIWWW.qblast("blastn",database=database, data=sequence_data, perc_ident=identity_threshold)
                blast_result_filename=f"blast_result_{genus}_{filefasta}_{database}.xml"
                     with open(blast_result_filename,"w") as blast_result:
                          blast_result.write(result_handle.read())
                     result_handle.close()

if __name__== "__main__":
    persearg(sys.argv)
 