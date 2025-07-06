#!/bin/bash
# Get the download type
PS3="Please select the type of images to be downloaded: "
downloadType=("Docker images" "Chart images")
selectedOpt=0

select res in "${downloadType[@]}"; do
    selectedOpt=$REPLY
    while [[ $REPLY != "1" && $REPLY != "2" ]]; do
        PS3="Please select a valid option for the image type to be downloaded: "
        select res in "${downloadType[@]}"; do
            selectedOpt=$REPLY
            break
        done
    done
    break
done

read -p "Please specify the remote server host: " serverHost
read -p "Please specify the remote server username: " server_username
read -p "Please specify the remote server port, press Enter to use the default port (22): " serverPort
read -p "Please specify path to the private key if exist, to skip press ENTER: " privateKey

# # Set default port
[ ${#serverPort} -gt 0 ] && prt=$serverPort || prt="22"

# Set default private key
[ ${#privateKey} -gt 0 ] && pk="-i $privateKey" || pk=""

# Local directories and files
init="./local_src/init.sh"
configDir="./config"
l_imageDir="./imgTemp/"
remote_src="./remote_src"

if [ $selectedOpt = "1" ]; then
    # Docker image download
    read -p "Please specify the file which contains the names of the images to be downloaded: " image_list_file

    # # Check if file exist
    if [ ! -f "$image_list_file" ]; then
        found=0
        while [ $found -eq 0 ]; do
            read -p "The '$image_list_file' does not exist, please specify a valid text file which contains the names of the images to be downloaded: " image_list_file
            if [ -f "$image_list_file" ]; then
                found=1
            fi
        done
    fi
else
    # Download chart images
    read -p "Enter the chartReference, example (zone/zonedependency): " chartRef
    read -p "Enter the version number for helm chart: " version_no
    releaseName=${chartRef//\//-}

fi

# Remote directories
dir="/tmp/airGapTempFiles"
r_configsDir="$dir/configs"
r_imageDir="$dir/images"
dockerImageOutputDir="$dir/tempOutput"

echo "Initiating remote server logging in, and image(s) download..."
done=0

if [ $selectedOpt = "1"  ]; then
    # Docker images download
    ssh -tp $prt $pk $server_username@$serverHost sudo "$r_configsDir/directImageDownload.sh" $image_list_file && done=1
else
    chartImageDir="$r_imageDir/$releaseName/$version_no"
    # Chart images download
    ssh -tp $prt $pk $server_username@$serverHost sudo "$r_configsDir/downloadAndCompressImages.sh" $releaseName $version_no $chartRef && done=1
fi

if [ $done -eq 1 ]; then
    echo -e "Image download completed successfully\n"
    echo "Initiating image download from the remote server to local server...."

    [ $selectedOpt = "1" ] && sourceDir=$dockerImageOutputDir || sourceDir=$chartImageDir

    scp -P $prt $pk -r $server_username@$serverHost:$sourceDir/* $l_imageDir &&
    echo -e "All images has been downloaded successfully....\n"
fi