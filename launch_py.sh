#!/bin/sh
#$ -cwd
#$ -j y
#$ -pe smp 1
#$ -l h_rt=24:0:0
#$ -l h_vmem=16G

# Activate virtualenv
source ~/pytools/bin/activate

# Run Python script
python ~/workspaces/py-tools/src/main.py mlr_hhi_8x8 ~/tests/mlr_8x8/results_nn **/dec.log 80 64 35 ~/tests/mlr_8x8/nn_%d_%d > model_8x8.txt

# Deactivate
deactivate
