README

1. Miniconda3/Anaconda3 Installation 

mkdir -p ~/miniconda3 
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/ miniconda3/miniconda.sh 
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3 
rm -rf ~/miniconda3/miniconda.sh 
~/miniconda3/bin/conda init bash

2. For the local installation on a Linux machine it is necesary guarantee the dependencies throught the conda enviroment, use the command inside the phallet_graph directory 

conda config --add channels defaults
conda config --add channels conda-forge
conda config --add channels bioconda 

conda env create --file dependencies.yaml

3. Using the bash scripts 06.Wraggling and 07.Graphing.sh for generate panels for the default version use: 

bash 06.wraggling.sh
bash 07.Graphing.sh

Inside the folder there is going to generate csv resumes and the graphs saved as PFDs
