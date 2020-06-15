#!/bin/sh
#$ -cwd
#$ -j y
#$ -pe smp 1
#$ -l h_rt=0:5:0
#$ -l h_vmem=1G

# shellcheck disable=SC1090
. "${HOME}/pyenv/bin/activate"

python "${HOME}/workspaces/phd-scripts/coding" --task merge_metrics --anchor_file anchor/summary.csv --test_file test/summary.csv --enc_file_rgx "./**/test_network.sh.*" --output_file metrics.xlsx

deactivate
