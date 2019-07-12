#!/bin/sh
#$ -cwd
#$ -j y
#$ -pe smp 1
#$ -l h_rt=1:0:0
#$ -l h_vmem=8G

# Activate virtualenv
source ~/pyenv/bin/activate

# Run Python script
INPUT_ARGS=$(sed -n "${SGE_TASK_ID}p" test_sequences.txt)
python  ~/workspaces/py-tools/src/main.py -t mode_count -d $PWD -b "**/decLog_"$INPUT_ARGS"*.out"

# Deactivate
deactivate
