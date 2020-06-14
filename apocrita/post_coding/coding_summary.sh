#!/bin/sh
#$ -cwd
#$ -j y
#$ -pe smp 1
#$ -l h_rt=1:0:0
#$ -l h_vmem=8G

source $HOME/pyenv/bin/activate

python $HOME/workspaces/py-tools/src/main.py --task coding_summary --config i_main10 --input_dir $PWD --enc_files **/encLog* --dec_files **/decLog* > summary.csv

deactivate
