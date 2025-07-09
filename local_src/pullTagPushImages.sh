#!/bin/bash
dir="/tmp/airGapTempFiles"
r_configsDir="$dir/configs"

read -p "Please specify the remote server host: " serverHost
read -p "Please specify the remote server username: " server_username
read -p "Please specify the remote server port, press Enter to use the default port (22): " serverPort
read -p "Please specify path to the private key if exist, to skip press ENTER: " privateKey

# # Set default port
[ ${#serverPort} -gt 0 ] && prt=$serverPort || prt="22"

# Set default private key
[ ${#privateKey} -gt 0 ] && pk="-i $privateKey" || pk=""

read -p "Please specify the file which contains the names (in the format: hostname/repository/imageName:tag) of the images to be pulled and tagged: " image_list_file

# # Check if file exist
if [ ! -f "$image_list_file" ]; then
    found=0
    while [ $found -eq 0 ]; do
        read -p "The '$image_list_file' does not exist, please specify a valid text file which contains the names of the images to be pulled: " image_list_file
        if [ -f "$image_list_file" ]; then
            found=1
        fi
    done
fi

# Convert image list to array
image_list=$(paste -sd ' ' "$image_list_file")

ssh -tp $prt $pk $server_username@$serverHost sudo "$r_configsDir/pullTagPush.sh" $image_list && done=1