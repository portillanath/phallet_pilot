#!/usr/bin/env python
# coding:utf-8

import os
import time 
import pandas as pd
import argparse
import getopt
import sys
import glob
from Bio import Entrez
from Bio.Blast import NCBIWWW
from Bio.Blast import NCBIXML
from Bio import SeqIO

def parsearg(argv):
    arg_identity_threshold = ""
    arg_blast_database = ""
    arg_help = "{0} -p <identity_threshold> -d <blast_database>".format(argv[0])
  
    try:
        opts, args = getopt.getopt(argv[1:], "p:d:", ["help", "identity_threshold=", "blast_database="])
    
    except:
        print(arg_help)
        sys.exit(2)
    
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            print(arg_help)
            sys.exit(2)
      
        elif opt in ("-p", "--identity_threshold"):
            arg_identity_threshold = arg
      
        elif opt in ("-d", "--blast_database"):
            arg_blast_database = arg
      
    print("identity_threshold", arg_identity_threshold)
    print("blast_database", arg_blast_database)

# List of possible arguments
identity_threshold = sys.argv[1]
blast_database = sys.argv[2]  
  
# Create a folder for sequences retrieved from feed
blast_feed = "./Blast_Feed"
os.makedirs(blast_feed, exist_ok=True)

os.chdir("Taxa_Selected")
genus_list = os.listdir(path=".")

# Now we are going to loop each fasta sequence per genus to display BLAST using the percentage identity display
for genus in genus_list:
    for filefasta in glob.glob("*.fasta", recursive=False):
        with open(os.path.join(os.getcwd(), filefasta), 'r') as fasta:
            sequence_data = open(fasta).read()
            for database in args.blast_database:
                result_handle = NCBIWWW.qblast("blastn", database=database, sequence_data=sequence_data, perc_ident=identity_threshold)
                blast_records = NCBIXML.parse(result_handle)
                
                #Create genus subdirectory in Blast_Feed
                genus_subdir=os.path.join(blast_feed,genus)
                os.makedirs(genus_subdir, exist_ok=True)
                
                #Save sequences with the identity percentage threshold
                
                for record in blast_records:
                    for alignment in record.alignments:
                        for hsp in alignment.hsps:
                            if (hsp.expect <= 1e-5) and (hsp.identities/alignment.length >= identity_threshold):
                              seq_id=alignment.hit_id
                              seq=Entrez.efetch(db="nucleotide", id=seq_id, rettype="gb", retmode="text").read()
                              seq_filename=os.path.join(genus_subdir,f"{seq_id}.gb")
                              with open(seq_filename,"w") as seq_file:
                                   seq_file.write(seq)
                                   
#Copy the orginal fasta file from the corresponding Taxa_Selected to Blast_Feed folder
shutil.copy(os.path.join(os.getcwd(), filefasta), genus_subdir)

if __name__ == "__main__":
    parsearg(sys.argv)
