#!/bin/bash

# -----------------------------------------------------------------
# Input arguments
# -----------------------------------------------------------------
encoder_bin=$1
num_sequences=$2
final_index=$(($num_sequences+3))

readonly SEQUENCE_NAME=("Tango2" "FoodMarket4" "Campfire" "CatRobot" "DaylightRod2" "ParkRunning3" "MarketPlace" "RitualDance" "Cactus" "BasketballDrive" "BQTerrace" "RaceHorsesC" "BQMall" "PartyScene" "BasketballDrill" "RaceHorses" "BQSquare" "BlowingBubbles" "BasketballPass" "FourPeople" "Johnny" "KristenAndSara")
readonly SEQUENCE_PATH=("Tango_4096x2160_60fps_10bit_420_jvet.yuv" "FoodMarket4_3840x2160_60fps_10bit_420.yuv" "Campfire_3840x2160_30fps_bt709_420_videoRange.yuv" "CatRobot_3840x2160_60fps_10bit_420_jvet.yuv" "DaylightRoad2_3840x2160_60fps_10bit_420.yuv" "ParkRunning3_3840x2160_50fps_10bit_420.yuv" "MarketPlace_1920x1080_60fps_10bit_420.yuv" "RitualDance_1920x1080_60fps_10bit_420.yuv" "Cactus_1920x1080_50.yuv" "BasketballDrive_1920x1080_50.yuv" "BQTerrace_1920x1080_60.yuv" "RaceHorses_832x480_30.yuv" "BQMall_832x480_60.yuv" "PartyScene_832x480_50.yuv" "BasketballDrill_832x480_50.yuv" "RaceHorses_416x240_30.yuv" "BQSquare_416x240_60.yuv" "BlowingBubbles_416x240_50.yuv" "BasketballPass_416x240_50.yuv" "FourPeople_1280x720_60.yuv" "Johnny_1280x720_60.yuv" "KristenAndSara_1280x720_60.yuv")
readonly SEQUENCE_DIR=("JVET/classA1/" "JVET/classA1/" "JVET/classA1/" "JVET/classA2/" "JVET/classA2/" "JVET/classA2/" "JVET/classB/" "JVET/classB/" "HD/" "HD/" "HD/" "CTC/class_C/" "CTC/class_C/" "CTC/class_C/" "CTC/class_C/" "CTC/class_D/" "CTC/class_D/" "CTC/class_D/" "CTC/class_D/" "720p/" "720p/" "720p/")

readonly QPs=(22 27 32 37)

for (( i=3;i<=$final_index;i++)); 
do 
    eval 'elem=${'$i'}'
done

eval 'cfg_parameters=${'$#'}'

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

# -----------------------------------------------------------------
# Sequence info
# -----------------------------------------------------------------
currDirectory=$SEQUENCE_ROOT${SEQUENCE_DIR[$curr_sequence]}
currSequenceName=${SEQUENCE_NAME[$curr_sequence]}
currSequenceFullName=${SEQUENCE_PATH[$curr_sequence]}
currInputFile=$currDirectory$currSequenceFullName
currSequenceFullName=$(echo $currSequenceFullName | cut -d'.' -f 1)
currSequenceCfg="~/workspaces/VVCSoftware_VTM/cfg/per-sequence/"$currSequenceName".cfg"

# -----------------------------------------------------------------
# Options
# -----------------------------------------------------------------
currQP=${QPs[$curr_qp]}

# -----------------------------------------------------------------
# Output files
# -----------------------------------------------------------------
currOutputLabel=$currSequenceName"_QP_"$currQP
config_file="~/workspaces/VVCSoftware_VTM/cfg/encoder_intra_vtm.cfg"
log_file="encLog_"$currOutputLabel".out"
BitstreamFile="encStr_"$currOutputLabel".bin"
DecodedFile="encRec_"$currOutputLabel".yuv"

# -----------------------------------------------------------------
# Actual process
# -----------------------------------------------------------------
enc_arg_string=" -c "$config_file" -c "$currSequenceCfg" --InputFile="$currInputFile" --QP="$currQP" --BitstreamFile="$BitstreamFile" --ReconFile="$DecodedFile" $cfg_parameters"

eval "/usr/bin/time -p $encoder_bin $enc_arg_string >> $log_file"
eval "rm "$DecodedFile
