#!/bin/bash

# Remote directories
dir="/tmp/airGapTempFiles"
configsDir="$dir/configs"
imageDir="$dir/images"

trackDir="$dir/track/docker"
dockerImageDir="$imageDir/docker"
output=$dir"/tempOutput"
type=$1
targetChartRef=$2
versionNo=$3

shift 3  # Remove first 3 args
image_list=("$@")  # Capture the rest as image list

if [ ! -d $output ]; then
    # Directory does not exist
    mkdir -p $output
    chmod a+wr $output
else
    # empty the directory
    rm -fr $output/*
fi

if [[ $type = "3" || $type = "4" ]]; then 
    # specific  pulled Docker images
    
    echo -e "Initiating marking of images to be downloaded...\n"

    for image in "${image_list[@]}"; do
        # check if images is downloaded aleady
        image_name=$(echo $image | cut -d'/' -f 3)
        safeName="${image_name//:/__}"

        if [ $type = "4" ]; then
            # specific  pulled Chart images 
            targetImage="$imageDir/$targetChartRef/$versionNo/$safeName.tar.gz"
        else
            targetImage="$dockerImageDir/$safeName.tar.gz"
        fi

        # Check for target files and mark
        if [ -f $targetImage ]; then
            # File exist, copy to output directory
            cp $targetImage $output/$safeName.tar.gz
            echo -e "The image $image_name has been marked for download\n"   
        else
            echo -e "Error: The  $image_name image has not been pulled yet, kindly try downloading the image before attempting to download the pulled images\n"
        fi

    done

fi