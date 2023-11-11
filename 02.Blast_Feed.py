import os
import glob
import sys
import argparse
from Bio import Entrez
from Bio.Blast import NCBIWWW
from Bio.Blast import NCBIXML

def parse_args():
    parser = argparse.ArgumentParser(description="Run BLAST on a set of FASTA files")
    parser.add_argument("-p", "--identity_threshold", type=float, default=70.0, help="Minimum percentage identity threshold for BLAST hits")
    parser.add_argument("-d", "--blast_databases", type=str, default="NCBI,Refseq", help="Comma-separated list of BLAST databases to search")
    return parser.parse_args()

args = parse_args()

identity_threshold = args.identity_threshold
blast_databases = args.blast_databases.split(',')

# Create a folder for sequences retrieved from feed
blast_feed = "./Blast_Feed"
os.makedirs(blast_feed, exist_ok=True)

os.chdir("Taxa_Selected")
genus_list = os.listdir(path=".")

# Now we are going to loop each fasta sequence per genus to display BLAST using the percentage identity display
for genus in genus_list:
    os.chdir(genus)
    fastas_files = glob.glob("*.fasta", recursive=False)
    for filefasta in fastas_files:
        with open(os.path.join(os.getcwd(), filefasta), 'r') as fasta:
            sequence_data = fasta.read()
            for database in blast_databases:
                print(f"Running BLAST for {filefasta} against database {database}")
                
                # Retry logic to handle possible XML format issues
                max_retries = 3
                for retry in range(max_retries):
                    try:
                        result_handle = NCBIWWW.qblast("blastn", database=database, sequence=sequence_data, perc_ident=identity_threshold)
                        blast_records = NCBIXML.parse(result_handle)
                        break  # Break out of the retry loop if successful
                    except ValueError as e:
                        print(f"Error fetching BLAST result. Retrying... ({retry + 1}/{max_retries})")
                        if retry == max_retries - 1:
                            print(f"Max retries reached. Skipping {filefasta} against {database}")
                            continue
                
                # Create genus subdirectory in Blast_Feed
                genus_subdir = os.path.join(blast_feed, genus)
                os.makedirs(genus_subdir, exist_ok=True)

                # Save sequences with the identity percentage threshold
                for record in blast_records:
                    for alignment in record.alignments:
                        for hsp in alignment.hsps:
                            if (hsp.expect <= 1e-5) and (hsp.identities / alignment.length >= float(identity_threshold)):
                                seq_id = alignment.hit_id
                                seq = Entrez.efetch(db="nucleotide", id=seq_id, rettype="gb", retmode="text").read()
                                seq_filename = os.path.join(genus_subdir, f"{seq_id}.gb")
                                with open(seq_filename, "w") as seq_file:
                                    seq_file.write(seq)
                                print(f"Downloaded sequence {seq_id} with identity {hsp.identities / alignment.length}")

                                # Open the original fasta file
                                with open(os.path.join(genus_subdir, os.path.basename(filefasta)), "w") as dest_file:
                                    dest_file.write(sequence_data)