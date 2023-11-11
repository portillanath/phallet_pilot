# phallet
Viral Taxonomy Genomic distance Profiler

Requirements 

1.Miniconda3 Installation

Linux/MacOS

mkdir -p ~/miniconda3

wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/

miniconda3/miniconda.sh

bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3

rm -rf ~/miniconda3/miniconda.sh

~/miniconda3/bin/conda init bash

2. Install all dependencies

chmod +x dependencies.sh
  
4. Run the default mode 

cd phallet

chmod +x phallet.sh

For allocate memory for running on local machine 
ulimit -v unlimited

bash phalllet.sh

