#!/bin/sh
#$ -cwd
#$ -j y
#$ -pe smp 1
#$ -l h_rt=1:0:0
#$ -l h_vmem=8G
#$ -t 1-18

source $HOME/pyenv/bin/activate

INPUT_ARGS=$(sed -n "${SGE_TASK_ID}p" test_sequences.txt)
python $HOME/workspaces/py-tools/src/main.py -t mode_count -d $PWD -b "**/decLog_"$INPUT_ARGS"*.out" > "modes_"$INPUT_ARGS".csv"

deactivate
