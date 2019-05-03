#!/bin/sh
#$ -cwd
#$ -j y
#$ -pe smp 1
#$ -l h_rt=1:0:0
#$ -l h_vmem=8G

# Activate virtualenv
source ~/pyenv/bin/activate

# Run Python script
python  ~/workspaces/py-tools/src/summary.py $PWD **/encLog* **/decLog* > results.csv

# Deactivate
deactivate
