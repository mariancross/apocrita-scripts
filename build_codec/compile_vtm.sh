#!/bin/bash
#$ -cwd -V
#$ -l node_type=nxv
#$ -j y
#$ -l h_rt=0:10:0
#$ -l h_vmem=8G
module load cmake/3.16.0
module load gcc/7.1.0
module load openmpi/3.1.2-gcc
./build_vtm.sh clean
