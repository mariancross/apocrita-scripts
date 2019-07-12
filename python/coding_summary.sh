#!/bin/sh
#$ -cwd
#$ -j y
#$ -pe smp 1
#$ -l h_rt=1:0:0
#$ -l h_vmem=8G

source ~/pyenv/bin/activate

python ~/workspaces/py-tools/src/main.py -t coding_summary -d  $PWD -e **/encLog* -b **/decLog* > results.csv

deactivate
