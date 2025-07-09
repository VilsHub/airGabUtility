#!/bin/bash
# Get the download type
PS3="Please select your desired task: "
taskType=("Initialize script" "Download Images" "Get pulled Images" "Extract and import images" "Get chart image list" "Generate new image list" "Uninstall script" "Manage local registry for CRIO" "Pull, Tag and Push Images")
selectedOpt=0

select res in "${taskType[@]}"; do
    selectedOpt=$(($REPLY))
    while [[ $selectedOpt -lt 1 ||  $selectedOpt -gt 9 ]]; do
        echo -e "\n"
        PS3="Please select a valid option for the task type: "
        select res in "${taskType[@]}"; do
            selectedOpt=$REPLY
            break
        done
    done
    echo $selectedOpt
    break
done

echo -e "\n"

if [ $selectedOpt = "1" ]; then
    . ./local_src/initialize.sh
elif [ $selectedOpt = "2" ]; then
    . ./local_src/downloadImages.sh
elif [ $selectedOpt = "3" ]; then
    . ./local_src/downloadPulledImages.sh
elif [ $selectedOpt = "4" ]; then
    . ./local_src/extractAndImportImages.sh
elif [ $selectedOpt = "5" ]; then
    . ./local_src/getChartImageList.sh
elif [ $selectedOpt = "6" ]; then
    . ./local_src/generateNewImageList.sh
elif [ $selectedOpt = "7" ]; then
    . ./local_src/clearTempFiles.sh
elif [ $selectedOpt = "8" ]; then
    . ./local_src/manageLocalRegistry.sh
elif [ $selectedOpt = "9" ]; then
    . ./local_src/pullTagPushImages.sh
fi