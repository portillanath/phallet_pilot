#Following the steps on this script update the ICTV viral Resource taxonomy classification 

#First step is intall crontab as a conda enviroment 
conda create -n crocrontab -lcrontab -lntab
conda activate crontab
#Installation thorugh bioconda 
conda install -c conda-forge crontab

#Now copy the personal bashrc 
nano ~/.bashrc 
#Create a new bashr to path the crontab 
nano ~/.bashrc_conda

#The following script set up the new root 
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/hpcfs/home/ciencias_biologicas/na.portilla10/anaconda3_install/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/hpcfs/home/ciencias_biologicas/na.portilla10/anaconda3_install/etc/profile.d/conda.sh" ]; then
        . "/hpcfs/home/ciencias_biologicas/na.portilla10/anaconda3_install/etc/profile.d/conda.sh"
    else
        export PATH="/hpcfs/home/ciencias_biologicas/na.portilla10/anaconda3_install/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

. "$HOME/.cargo/env"

#After this, a new crontab job is made 
crontab -e

SHELL=/bin/bash
BASH_ENV=~/.bashrc_conda

30 12 * * * wget https://ictv.global/vmr/current > /hpcfs/home/ciencias_biologicas/na.portilla10/Source_PhageClouds/Virus_Metadata_Resource | rm `ls -t | awk 'NR>1'`

#To check the status 
crontab -l


