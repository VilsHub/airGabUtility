#!/bin/bash
# Get the download type
PS3="Please select ypur desired task: "
taskType=("Initialize script" "Download Chart images" "Download docker images")
selectedOpt=0

select res in "${taskType[@]}"; do
    selectedOpt=$REPLY
    while [[ $REPLY != "1" && $REPLY != "2" && $REPLY != "3" ]]; do
        PS3="Please select a valid option for the task type: "
        select res in "${taskType[@]}"; do
            selectedOpt=$REPLY
            break
        done
    done
    break
done


if [ $selectedOpt = "1" ]; then
    . ./initialize.sh
fi
