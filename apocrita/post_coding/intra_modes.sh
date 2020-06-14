#!/bin/sh
#$ -cwd
#$ -j y
#$ -pe smp 1
#$ -l h_rt=0:15:0
#$ -l h_vmem=8G
#$ -t 1-18

# shellcheck disable=SC1090
. "${HOME}/pyenv/bin/activate"

INPUT_ARGS=$(sed -n "${SGE_TASK_ID}p" test_sequences.txt)
python "${HOME}/workspaces/phd=scripts/coding" --task intra_modes --input_dir "${PWD}" --dec_file_rgx "**/decLog_"${INPUT_ARGS}"*.out" --output_file "modes_"${INPUT_ARGS}".xlsx"

deactivate
