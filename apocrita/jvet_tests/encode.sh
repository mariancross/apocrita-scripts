#!/bin/bash
#
# Experiment description
#
# Test set:
# Class A1 1:3 (1:12)
# Class A2 4:6 (13:24)
# Class B 7:11 (25:44)
# Class C 12:15 (45:60)
# Class D 16:19 (61:76)
# Class E 20:22 (77:88)
#
test_set=($(seq 1 1 88))
# test_set=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88)
#
# Additional cfg parameters:
cfg_parameters='--FramesToBeEncoded=1 --SEIDecodedPictureHash=1'
#
# Executable:
name_of_executable='bin/bin/EncoderAppStatic'
#
#$ -cwd -V
#$ -j y
#$ -l h_rt=3:0:0
#$ -l h_vmem=3G
#$ -l node_type=nxv
#$ -t 1-88
num_sequences=${#test_set[@]}
./enc_jvet.sh $name_of_executable $num_sequences ${test_set[@]} "$cfg_parameters"
