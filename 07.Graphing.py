import os
import re
import glob
import pandas as pd
import numpy as np
import sys
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

# Set working directory
workdir = os.path.expanduser("~/phallet/Metrics_Results")
subdirectories=[d for d in os.listdir(workdir)]

# Read command-line arguments
args = sys.argv[1:]
mx = "ani"
kmersx = [12, 11, 10, 9, 8]
my = "mash"
kmersy = [15, 17, 20, 21, 24]

# Remove any arguments that are not valid integers
args = [arg for arg in args if re.match(r'^\d+$', arg)]

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

metrics = [mx, my]

ani_data=pd.DataFrame()
mash_data=pd.DataFrame()
viridic_data=pd.DataFrame()

for m in metrics:
        if m==mx:
            kmers=kmersx
            tool_mx=tool_mx
        if m==my:
            kmers=kmersy
            tool_my=tool_my
# Retrieve information for each metric

for genus in subdirectories:
    os.chdir(workdir)
    genus_name = os.path.basename(genus)
    genus_dir= os.path.join(workdir,genus_name)
    summaries = glob.glob(os.path.join(genus_dir,"*metrics*.csv"))

    if mx in metrics:
        mx_data = pd.read_csv([s for s in summaries if f"{mx}_metrics_" in s][0])
        kmer_values_mx = sorted(pd.unique(mx_data[f"kmer_{mx}"]))
    
    if my in metrics:
        my_data = pd.read_csv([s for s in summaries if f"{my}_metrics_" in s][0])
        kmer_values_my = sorted(pd.unique(my_data[f"kmer_{my}"]))
        
# Assuming merged_df is your DataFrame
for i, algorithm_mx in enumerate(tool_mx):
    for j, algorithm_my in enumerate(tool_my):

        # Subset the data for the current combination
        df_subset_mx = mx_data[mx_data["algorithm"]==algorithm_mx]
        df_subset_my = my_data[my_data["algorithm"]==algorithm_my]

        # Create a scatterplot for each kmer combination
        for mx_kmer in kmer_values_mx:
            for my_kmer in kmer_values_my:

                # Subset the data for the current kmer_mx and kmer_my
                df_subset_mx_kmer = df_subset_mx[df_subset_mx[f"kmer_{mx}"] == mx_kmer]
                df_subset_my_kmer = df_subset_my[df_subset_my[f"kmer_{my}"] == my_kmer]
                merged_df = pd.merge(df_subset_my_kmer, df_subset_mx_kmer, left_on="GenomeA", right_on="GenomeB")

                # Create a scatterplot for the current kmer_mx and kmer_my
                fig, ax = plt.subplots(figsize=(8, 6))
                ax.scatter(merged_df.iloc[:, 7], merged_df.iloc[:, 2])
                ax.axvline(x=95, color="black")
                ax.set_xlabel(mx)
                ax.set_ylabel(my)
                ax.set_title(f"{algorithm_mx}, {algorithm_my}, {mx_kmer}, {my_kmer}")

                # Save the current figure to a PDF file
                pdf_filename = f"{algorithm_mx}_{algorithm_my}_{mx_kmer}_{my_kmer}.pdf"
                with PdfPages(pdf_filename) as pdf:
                    pdf.savefig(fig)

# Show a message when the PDF files have been created
print("PDF files created successfully.")