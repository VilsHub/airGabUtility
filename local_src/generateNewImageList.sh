#!/bin/bash
echo -e "\nThis will help generate a new image list of non downloaded images from an existing images list"
read -p "Please specify the existing image list (in the format: hostname/repository/imageName:tag) file: " oldImageListFile

# Local directories
l_imageDir="./imgTemp"
l_configsDir="./configs"

#Check if file exist
if [ ! -f "$oldImageListFile" ]; then
    found=0
    while [ $found -eq 0 ]; do
        read -p "The '$oldImageListFile' does not exist, please specify the target file which contains the names (in the format: hostname/repository/imageName:tag) of the images to be doownloaded: " oldImageListFile
        if [ -f "$oldImageListFile" ]; then
            found=1
        fi
    done
fi

read -p "Please specify the name of the new image list file: " newImageListFile

#Check if file exist
selectedOpt=0
if [ -f "$newImageListFile" ]; then
    
    PS3="The image list file exist, what would you like to do?: "
    action=("Override" "Create new File")

    select res in "${action[@]}"; do
        selectedOpt=$REPLY
        while [[ $REPLY != "1" && $REPLY != "2" ]]; do
            PS3="Please select a valid option for what you want to do: "
            select res in "${action[@]}"; do
                selectedOpt=$REPLY
                break
            done
        done
        break
    done

fi

# Compute file new name
if [[ $selectedOpt -eq 0 || $selectedOpt = "1" ]]; then
    # New file
    fileName=$newImageListFile

elif [ $selectedOpt = "2" ]; then
    read -p "specify the name of the new image list file, different from '$newImageListFile' " nFileName

    if [ $nFileName = $newImageListFile ]; then
        same=1
        while [ $same -eq 1 ]; do
            read -p "The specified file name is the same as '$newImageListFile' please supply a file name different from '$newImageListFile' :  " nFileName
            if [ $nFileName != $newImageListFile ]; then
                same=0
            fi
        done
    fi

    fileName=$nFileName

fi

count=0
nImageList="$fileName"
rm -f $nImageList
while read image; do
    # check if images is downloaded aleady
    image_name=$(echo $image | cut -d'/' -f 3)
    targetImageFile="$l_imageDir/$image_name.tar.gz"
    fullImageName="$l_imageDir/$image.tar.gz"

    if [ ! -f $targetImageFile ]; then
        # File does not exist
        echo "$image" >> $nImageList
        ((count += 1 ))
    fi

done < "$oldImageListFile"

if [ $count -gt 0 ]; then
    echo "New image list file '$fileName' has been created with $count undownloaded images"
else
    echo "No undownloaded image found to extract"
fi