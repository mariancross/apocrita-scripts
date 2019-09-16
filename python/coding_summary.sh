#!/bin/sh
#$ -cwd
#$ -j y
#$ -pe smp 1
#$ -l h_rt=1:0:0
#$ -l h_vmem=8G

source $HOME/pyenv/bin/activate

python $HOME/workspaces/py-tools/src/main.py -c i_main10 -t coding_summary -d  $PWD -e **/encLog* -b **/decLog*

deactivate
