#!/bin/sh
#$ -cwd
#$ -j y
#$ -pe smp 1
#$ -l h_rt=0:15:0
#$ -l h_vmem=8G

# shellcheck disable=SC1090
. "${HOME}/pyenv/bin/activate"

python "${HOME}/workspaces/phd-scripts/coding" --task intra_modes --dir "${PWD}" --dec_file_rgx ./**/decLog* --output_file "modes.xlsx"

deactivate
