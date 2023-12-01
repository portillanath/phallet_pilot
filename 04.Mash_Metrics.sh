#!/bin/bash

#Default kmers values
kmers=(15 17 20 21 24)
genus=""

while getopts "k:g:" opt;do
    case ${opt} in
        k )
            kmers=(${OPTARG})
            ;;
        g ) 
            genus=(${OPTARG})
            ;;
        \? )
            echo "Invalid option: $OPTARG" 1>&2
            ;;
    esac
done

# Create variables for paths
source=~/phallet/Blast_Feed
mkdir -p Metrics_Results
outdir=~/phallet/Metrics_Results

# Create a list of subdirectories within the working directory
if [ -n "$genus" ]; then
  # If a genus name is provided, only process that genus
  subdirs=("$source/$genus")
else
  # Otherwise, process all subdirectories
  subdirs=($(find "$source" -mindepth 1 -type d))
fi

# Loop through each subdirectory
for subdir in "${subdirs[@]}"; do
  subdir_basename=$(basename "$subdir")
  cd "$subdir"

  # MASH ALGORITHM
  # Load mash and sourmash
  source activate mash

  # Create a sketch of all the sequences
  # Use 64-bit hashes and a sketch default of 1000
  for k in "${kmers[@]}"; do
    mash sketch -k ${k} -o ${subdir}/sketch_mash_${subdir_basename}_${k} ${subdir}/*.fasta
    echo "The sketching is complete for $subdir_basename with kmer $k"
    # Calculate mash distance with the sketches
    mash dist ${subdir}/sketch_mash_${subdir_basename}_${k}.msh ${subdir}/sketch_mash_${subdir_basename}_${k}.msh > ${subdir}/mash_distance_${subdir_basename}_k${k}.tab
    echo "The matrix distance is calculated for $subdir_basename with kmer $k"
  done

  mv sketch* $outdir
  mv *.tab $outdir

  #SOURMASH ALGORITHM

    # Create an "," array of kmers 
  kmerslist=""
  for k in "${kmers[@]}";do
    kmerslist="${kmerslist}${k},"
  done
  kmerslist=${kmerslist::-1}
  echo "$kmerslist"
 
  #Create the signatures subdirectory inside each subdir
  sig_subdir_basename="signatures_${subdir_basename}"
  mkdir -p ${subdir}/${sig_subdir_basename}

  sourmash compute --ksizes "${kmerslist}" *.fasta --singleton

  #Move the signatures to the newly created subdirectory
  mv *.sig "${subdir}/${sig_subdir_basename}/"
  echo "All the signatures were moved"

#Run sourmash compare inside the current subdir
for k in ${kmers[@]}; do
  sourmash compare --k ${k} --csv ${subdir}/sourmash_distance_${subdir_basename}_k${k}.csv ${subdir}/${sig_subdir_basename}/*.sig
  echo "The matrix distance is calculated for $subdir_basename with kmer $k"
done

mv sourmash* $outdir

done

