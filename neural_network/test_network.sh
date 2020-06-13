#!/bin/sh
#$ -cwd
#$ -j y
#$ -pe smp 1
#$ -l h_rt=1:0:0
#$ -l h_vmem=8G
#$ -t 1-18

source $HOME/pyenv/bin/activate

python $HOME/workspaces/intra-prediction-tf/main_alwip.py --task test --yuv_path video.yuv --yuv_width 1280 -- yuv_height 720 --bit_depth 10 --pred_path output.png
