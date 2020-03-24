#!/bin/bash
full_run=$1
configuration=$2
encoder_bin=$3
num_sequences=$4
final_index=$(($num_sequences+4))
testset=()

readonly SEQUENCE_ROOT=$SEQUENCES_PATH
readonly SEQUENCE_NAMES=("Traffic_2560x1600_30_crop.yuv" "PeopleOnStreet_2560x1600_30_crop.yuv" "Kimono1_1920x1080_24_8bit_420.yuv" "ParkScene_1920x1080_24_8bit_420.yuv" "Cactus_1920x1080_50.yuv" "BQTerrace_1920x1080_60.yuv" "BasketballDrive_1920x1080_50.yuv" "RaceHorses_832x480_30.yuv" "BQMall_832x480_60.yuv" "PartyScene_832x480_50.yuv" "BasketballDrill_832x480_50.yuv" "RaceHorses_416x240_30.yuv" "BQSquare_416x240_60.yuv" "BlowingBubbles_416x240_50.yuv" "BasketballPass_416x240_50.yuv" "FourPeople_1280x720_60.yuv" "Johnny_1280x720_60.yuv" "KristenAndSara_1280x720_60.yuv")
readonly SEQUENCE_DIRS=("1600p/" "1600p/" "HD/" "HD/" "HD/" "HD/" "HD/" "CTC/class_C/" "CTC/class_C/" "CTC/class_C/" "CTC/class_C/" "CTC/class_D/" "CTC/class_D/" "CTC/class_D/" "CTC/class_D/" "720p/" "720p/" "720p/")
readonly SEQUENCE_NUM_FRAMES=(150 150 240 240 500 600 500 300 600 500 500 300 600 500 500 600 600 600)
readonly SEQUENCE_SKIP_FRAMES=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
readonly SEQUENCE_WIDTHS=(2560 2560 1920 1920 1920 1920 1920 832 832 832 832 416 416 416 416 1280 1280 1280)
readonly SEQUENCE_HEIGHTS=(1600 1600 1080 1080 1080 1080 1080 480 480 480 480 240 240 240 240 720 720 720)
readonly SEQUENCE_FRAME_RATES=(30 30 24 24 50 60 50 30 60 50 50 30 60 50 50 60 60 60)

readonly QPs=(22 27 32 37)

for (( i=5;i<=$final_index;i++)); 
do 
    eval 'elem=${'$i'}'
    eval 'testset+=($'$elem')'
done

eval 'cfg_parameters=${'$#'}'


#Check if current point must be tested:
curr_job=$SGE_TASK_ID
curr_sequence=$((($curr_job-1)/4))
curr_qp=$((($curr_job-1)%4))
testThisPoint=0
for (( i=5;i<=$final_index;i++)); 
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
currDirectory=$SEQUENCE_ROOT${SEQUENCE_DIRS[$curr_sequence]}
currSequenceName=${SEQUENCE_NAMES[$curr_sequence]}
currInputFile=$currDirectory$currSequenceName
currSequenceName=$(echo $currSequenceName | cut -d'.' -f 1)
currNumFrames=${SEQUENCE_NUM_FRAMES[$curr_sequence]}
currSkipFrames=${SEQUENCE_SKIP_FRAMES[$curr_sequence]}
width=${SEQUENCE_WIDTHS[$curr_sequence]}
height=${SEQUENCE_HEIGHTS[$curr_sequence]}
currFrameRate=${SEQUENCE_FRAME_RATES[$curr_sequence]}

# -----------------------------------------------------------------
# Options
# -----------------------------------------------------------------
currQP=${QPs[$curr_qp]}

# -----------------------------------------------------------------
# Output files
# -----------------------------------------------------------------
currOutputLabel=$currSequenceName"_QP_"$currQP
BitstreamFile=" "
DecodedFile=" "
config_file="~/workspaces/VVCSoftware_VTM/cfg/encoder_intra_vtm.cfg"
log_file=" "

if [ $configuration -eq 1 ];
then
    log_file="encLog_"$currOutputLabel".out"
    BitstreamFile="encStr_"$currOutputLabel".bin"
    DecodedFile="encRec_"$currOutputLabel".yuv"
else
    log_file="encLog_onlyAng_"$currOutputLabel".out"
    BitstreamFile="encStr_onlyAng_"$currOutputLabel".bin"
    DecodedFile="encRec_onlyAng_"$currOutputLabel".yuv"
fi

# -----------------------------------------------------------------
# Actual process
# -----------------------------------------------------------------
enc_arg_string=" -c "$config_file" --InputFile="$currInputFile" --QP="$currQP" --FramesToBeEncoded="$currNumFrames" --FrameSkip="$currSkipFrames" --FrameRate="$currFrameRate" --BitstreamFile="$BitstreamFile" --ReconFile="$DecodedFile" --SourceWidth="$width" --SourceHeight="$height" --SEIDecodedPictureHash=1 --Verbosity=6"

eval "/usr/bin/time -p $encoder_bin $enc_arg_string >> $log_file"
eval "cat *.$SGE_TASK_ID | tail -n 3 >> $log_file"
eval "rm "${DecodedFile}
