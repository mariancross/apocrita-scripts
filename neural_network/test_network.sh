#!/bin/sh
#$ -cwd
#$ -j y
#$ -pe smp 1
#$ -l h_rt=1:0:0
#$ -l h_vmem=8G
#$ -t 1-18

source $HOME/pyenv/bin/activate

INPUT_ARGS=$(sed -n "${SGE_TASK_ID}p" nn_args.txt)
python $HOME/workspaces/intra-prediction-tf/main_alwip.py --task test --bit_depth 10 $INPUT_ARGS

deactivate
