#!/bin/bash
decoder_bin=$1
num_sequences=$2
final_index=$(($num_sequences+2))

readonly SEQUENCE_ROOT=$PWD
readonly SEQUENCE_NAMES=("Traffic_2560x1600_30_crop" "PeopleOnStreet_2560x1600_30_crop" "Kimono1_1920x1080_24_8bit_420" "ParkScene_1920x1080_24_8bit_420" "Cactus_1920x1080_50" "BQTerrace_1920x1080_60" "BasketballDrive_1920x1080_50" "RaceHorses_832x480_30" "BQMall_832x480_60" "PartyScene_832x480_50" "BasketballDrill_832x480_50" "RaceHorses_416x240_30" "BQSquare_416x240_60" "BlowingBubbles_416x240_50" "BasketballPass_416x240_50" "FourPeople_1280x720_60" "Johnny_1280x720_60" "KristenAndSara_1280x720_60")
readonly QPs=(22 27 32 37)

#Check if current point must be tested:
curr_job=$SGE_TASK_ID
curr_sequence=$((($curr_job-1)/4))
curr_qp=$((($curr_job-1)%4))
testThisPoint=0
for (( i=3;i<=$final_index;i++)); 
do 
    eval 'elem=${'$i'}'
    seqInd=$(($curr_sequence+1))
    if [ $seqInd -eq $elem ];
    then
        testThisPoint=$(($testThisPoint+1))
        break
    fi
done

if [ $testThisPoint -eq 0 ]; 
then
    exit
fi

currDir=$SEQUENCE_ROOT
currSequenceName=${SEQUENCE_NAMES[$curr_sequence]}

currQP=${QPs[$curr_qp]}

currOutputLabel=$currSequenceName"_QP_"$currQP
BitstreamFile=$currDir"encStr_"$currOutputLabel".bin"
DecodedFile=$currDir"decRec_"$currOutputLabel".yuv"
LogFile=$currDir"decLog_"$currOutputLabel".out"

dec_arg_string=" -b "$BitstreamFile" --ReconFile="$DecodedFile""

eval "/usr/bin/time -p $decoder_bin $dec_arg_string > $LogFile"
# eval "cat *.$SGE_TASK_ID | tail -n 3 >> $LogFile"
eval "rm "${DecodedFile}
