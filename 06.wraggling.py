
# Set paths
import os
import re
import sys
import pandas as pd
from glob import glob
import numpy as np
from scipy.spatial.distance import pdist
from scipy.spatial.distance import squareform


# Set paths
source = os.path.expanduser("~/phallet/Blast_Feed")
subdirectories = [d for d in os.listdir(source)]
workdir = os.path.expanduser("~/phallet/Metrics_Results")

# Create output directories
for genus in subdirectories:
    genus_name = os.path.basename(os.path.normpath(genus))
    genus_dir = os.path.join(workdir, genus_name)
    # Check if the directory already exists
    if not os.path.exists(genus_dir):
        os.makedirs(genus_dir)

        # Move all the file in workdir that match with the genus
        files_to_move = glob(os.path.join(workdir, f"*{genus_name}*"))
        for file in files_to_move:
            os.rename(file, os.path.join(genus_dir, os.path.basename(file) + "_new"))

# Read command-line arguments
args = sys.argv[1:]
mx = "ani"
kmersx = [12, 11, 10, 9, 8]
my = "mash"
kmersy = [15, 17, 20, 21, 24]

# Remove any arguments that are not valid integers
args = [arg for arg in args if re.match(r'^\d+$', arg)]

# Parse the remaining arguments
if len(args) > 0:
    mx = args[0]
if len(args) > 1:
    kmersx = list(map(int, args[1].split(",")))
if len(args) > 2:
    my = args[2]
if len(args) > 3:
    kmersy = list(map(int, args[3].split(",")))

# Set up directories on workdir
subdirectories = [d for d in os.listdir(workdir) if os.path.isdir(os.path.join(workdir, d))]

# SEARCH FOR OUTPUT FILES
# Recover possible algorithms for each metric of the pairwise correlation
# Cases for metrics selected available
if mx == "mash":
    tool_mx = ["mash", "sourmash"]
elif mx == "ani":
    tool_mx = ["fastani", "skani"]
elif mx == "aai":
    tool_mx = ["comparem"]
elif mx == "viridic":
    tool_mx = ["viridic"]
elif mx == "vcontact2":
    tool_mx = ["vcontact2"]
else:
    raise ValueError("Invalid metric selected")

# Cases for metrics selected on Y
if my == "mash":
    tool_my = ["mash", "sourmash"]
elif my == "ani":
    tool_my = ["fastani", "skani"]
elif my == "aai":
    tool_my = ["comparem"]
elif my == "viridic":
    tool_my = ["viridic"]
elif my == "vcontact2":
    tool_my = ["vcontact2"]
else:
    raise ValueError("Invalid metric selected")

metrics = [mx, my]

# This makes the parsing for the corresponding metric
fastani_results = pd.DataFrame()
skani_results = pd.DataFrame()
mash_results =pd.DataFrame()
sourmash_results=pd.DataFrame()

for subdir in subdirectories:
    os.chdir(workdir)
    if not os.path.exists(subdir):
        continue
    subdir_name = os.path.basename(subdir)
    genomes=[]
    for m in metrics:
        if m == mx:
            tool_list = tool_mx
            kmers = kmersx
        if m == my:
            tool_list = tool_my
            kmers = kmersy

        for tool in tool_list:

            # In case of having fastani metrics
            if tool == "fastani":
                files_fastani = glob(os.path.join(workdir, subdir_name, "fastani*"))
                files_fastani = [file for file in files_fastani if not file.endswith('.csv')]
                for file in files_fastani:
                    k = int(file.split("_")[-1].split(".")[0])
                    data_fastani = pd.read_csv(file, header=None, sep='\t')
                    data_fastani = data_fastani.iloc[:, :3]
                    data_fastani['kmer_ani'] = k
                    data_fastani['algorithm'] ="fastani"
                    data_fastani.columns = ["GenomeA", "GenomeB", "ani_distance", "kmer_ani","algorithm"]
                    data_fastani['GenomeA'] = data_fastani['GenomeA'].replace('.*/', '', regex=True)
                    data_fastani['GenomeB'] = data_fastani['GenomeB'].replace('.*/', '', regex=True)
                    data_fastani['GenomeA'] = data_fastani['GenomeA'].replace('.fasta', '', regex=True)
                    data_fastani['GenomeB'] = data_fastani['GenomeB'].replace('.fasta', '', regex=True)
                    fastani_results = pd.concat([fastani_results, data_fastani])
                
            fastani_results.to_csv(os.path.join(workdir, subdir_name, f"fastani_results_{subdir_name}.csv"), index=False)
            
            # In case of having skani metrics
            if tool=="skani":
             files_skani = glob(os.path.join(workdir, subdir_name, "skani*"))
             files_skani = [file for file in files_skani if not file.endswith('.csv')]
             for file in files_skani:  
                data_skani = pd.read_csv(file, header=None, sep='\t', names=["Ref_file","Query_file","ANI","Align_fraction_ref","Align_fraction_query","Ref_name","Query_name"])
                data_skani = data_skani.iloc[:, :3]
                data_skani['kmer_ani'] = "static"
                data_skani['algorithm'] ="skani"
                data_skani=data_skani.drop(index=0)
                data_skani.columns = ["GenomeA", "GenomeB", "ani_distance", "kmer_ani","algorithm"]
                data_skani['GenomeA'] = data_skani['GenomeA'].replace('.*/', '', regex=True)
                data_skani['GenomeB'] = data_skani['GenomeB'].replace('.*/', '', regex=True)
                data_skani['GenomeA'] = data_skani['GenomeA'].replace('.fasta', '', regex=True)
                data_skani['GenomeB'] = data_skani['GenomeB'].replace('.fasta', '', regex=True)
                skani_results = pd.concat([skani_results, data_skani])
            
            skani_results.to_csv(os.path.join(workdir, subdir_name, f"skani_results_{subdir_name}.csv"), index=False)   
            
            # In case of having mash metrics
            if tool=="mash":
             files_mash = glob(os.path.join(workdir, subdir_name, "mash*.tab"))
             for file in files_mash:
                k = int(re.search(r'k(\d+)', file).group(1))
                if k in kmers:
                    data_mash = pd.read_csv(file, header=None, names=["GenomeA", "GenomeB", "mash_distance", "p-value", "shared_hashes"], sep='\t')
                    data_mash = data_mash.iloc[:, :3]
                    data_mash['kmer_mash'] = k
                    data_mash['algorithm'] = "mash"
                    data_mash['GenomeA'] = data_mash['GenomeA'].replace('.*/', '', regex=True)
                    data_mash['GenomeB'] = data_mash['GenomeB'].replace('.*/', '', regex=True)
                    data_mash['GenomeA'] = data_mash['GenomeA'].replace('.fasta', '', regex=True)
                    data_mash['GenomeB'] = data_mash['GenomeB'].replace('.fasta', '', regex=True)
                    mash_results = pd.concat([mash_results, data_mash])
            mash_results.to_csv(os.path.join(workdir, subdir_name, f"mash_results_{subdir_name}.csv"), index=False)   

            # In case of having sourmash metrics
            if tool=="sourmash":
              files_sourmash = glob(os.path.join(workdir, subdir_name, "sourmash*.csv"))
              accessions_path=os.path.join(source,subdir_name)
              accessions= os.listdir(accessions_path)
              genomes= [os.path.splitext(file)[0] for file in accessions if file.endswith(".fasta")]
              for file in files_sourmash:
                k_values = [int(match.group(1)) for match in re.finditer(r'k(\d+)', file)]
                k = k_values[0] if k_values else None 
                #k = int(re.search(r"k(\d+)", file).group(1))
                if k in kmers:
                    data_sourmash = pd.read_csv(file, sep=',')
                    data_sourmash.columns = genomes
                    data_sourmash.index = genomes
                    data_sourmash=data_sourmash.to_numpy()
                    distances=pdist(data_sourmash)
                    square_distances=squareform(distances)
                    i,j=np.triu_indices(square_distances.shape[0],k=1)
                    data_sourmash = pd.DataFrame({"GenomeA": [genomes[int(idx)] for idx in i], "GenomeB": [genomes[int(idx)] for idx in j], "mash_distance": square_distances[i.astype(int), j.astype(int)]})
                    data_sourmash['kmer_mash'] = k
                    data_sourmash['algorithm']= "sourmash"
                    sourmash_results = pd.concat([sourmash_results, data_sourmash], ignore_index=True)

            mash_results.to_csv(os.path.join(workdir, subdir_name, f"sourmash_results_{subdir_name}.csv"), index=False)   

#Merge of differents compend
    ani_metrics_result=pd.concat([fastani_results,skani_results])
    ani_metrics_result.to_csv(os.path.join(workdir,subdir_name,f"ani_metrics_{subdir_name}.csv"), index=False)
    mash_metrics_result=pd.concat([mash_results,sourmash_results])
    mash_metrics_result.to_csv(os.path.join(workdir,subdir_name,f"mash_metrics_{subdir_name}.csv"), index=False)
         