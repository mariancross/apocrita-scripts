#!/bin/sh
#$ -cwd
#$ -j y
#$ -pe smp 1
#$ -l h_rt=0:10:0
#$ -l h_vmem=8G

# shellcheck disable=SC1090
. "${HOME}/pyenv/bin/activate"

python "${HOME}/workspaces/phd-scripts/coding" --task coding_summary --codec hevc --config i_main10 --dir "${PWD}" --enc_file_rgx ./**/encLog* --dec_file_rgx ./**/decLog* > summary.csv

deactivate
