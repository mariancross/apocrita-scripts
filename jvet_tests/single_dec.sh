#!/bin/bash

# -----------------------------------------------------------------
# Input arguments
# -----------------------------------------------------------------
encoder_bin=$1
num_sequences=$2
final_index=$(($num_sequences+3))

readonly SEQUENCE_NAME=("Tango2" "FoodMarket4" "Campfire" "CatRobot" "DaylightRoad2" "ParkRunning3" "MarketPlace" "RitualDance" "Cactus" "BasketballDrive" "BQTerrace" "RaceHorsesC" "BQMall" "PartyScene" "BasketballDrill" "RaceHorses" "BQSquare" "BlowingBubbles" "BasketballPass" "FourPeople" "Johnny" "KristenAndSara")
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

currDir=$PWD
currSequenceName=${SEQUENCE_NAMES[$curr_sequence]}

currQP=${QPs[$curr_qp]}

currOutputLabel=$currSequenceName"_QP_"$currQP
BitstreamFile=$currDir"encStr_"$currOutputLabel".bin"
DecodedFile=$currDir"decRec_"$currOutputLabel".yuv"
LogFile=$currDir"decLog_"$currOutputLabel".out"

dec_arg_string=" -b "$BitstreamFile" --ReconFile="$DecodedFile""

eval "/usr/bin/time -p $decoder_bin $dec_arg_string > $LogFile"
# eval "cat *.$SGE_TASK_ID | tail -n 3 >> $LogFile"
#eval "rm "${DecodedFile}
