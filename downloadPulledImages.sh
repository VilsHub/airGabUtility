#!/bin/bash
# Get the pull type
PS3="Please select the type of pulled images to be downloaded: "
pullType=("All docker images" "All pulled chart images" "Specific pulled docker images" "Specific pulled chart images")
selectedOpt=0
releaseName=""

select res in "${pullType[@]}"; do
    selectedOpt=$REPLY
    while [[ $REPLY != "1" && $REPLY != "2" && $REPLY != "3" && $REPLY != "4" ]]; do
        PS3="Please select a valid option for the pulled images to be downloaded: "
        select res in "${pullType[@]}"; do
            selectedOpt=$REPLY
            break
        done
    done
    break
done

# Local directories and files
init="./local_src/init.sh"
l_imageDir="./imgTemp/"
remote_src="./remote_src"

read -p "Please specify the remote server host: " serverHost
read -p "Please specify the remote server username: " server_username
read -p "Please specify the remote server port, press Enter to use the default port (22): " serverPort
read -p "Please specify path to the private key if exist, to skip press ENTER: " privateKey

# Set default port
[ ${#serverPort} -gt 0 ] && prt=$serverPort || prt="22"

# Set default private key
[ ${#privateKey} -gt 0 ] && pk="-i $privateKey" || pk=""

# Remote directories
dir="/tmp/airGapTempFiles"
r_configsDir="$dir/configs"
r_imageDir="$dir/images"
dockerImageDir="$r_imageDir/docker"


if [ $selectedOpt = "1" ]; then
    # Download pulled docker images

    echo "Initiating image download from the remote server to local server...."
    scp -P $prt $pk -r $server_username@$serverHost:$dockerImageDir/* $l_imageDir
    echo -e "All images has been downloaded successfully....\n"

elif [ $selectedOpt = "2" ]; then
    # Download all pulled chart images
    read -p "Enter the chartReference, example (zone/zonedependency): " chartRef
    read -p "Enter the version number for helm chart: " version_no
    releaseName=${chartRef//\//-}

    chartImageDir="$r_imageDir/$releaseName/$version_no"

    echo "Initiating image download from the remote server to local server...."
    scp -P $prt $pk -r $server_username@$serverHost:$chartImageDir/* $l_imageDir
    echo -e "All images has been downloaded successfully....\n"

elif [ $selectedOpt = "3" ]; then
    # Specific pulled docker images
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
elif [ $selectedOpt = "4" ]; then
    # Specific pulled chart images
    read -p "Enter the chartReference, example (zone/zonedependency): " chartRef
    read -p "Enter the version number for helm chart: " version_no
    releaseName=${chartRef//\//-}
    read -p "Has the $releaseName chart version $version_no been downloaded before, with the temp files stil on the remote server? y/n: " downloaded

    if [[ $downloaded = "y" && $downloaded = "Y" ]]; then
        echo "Please kindly download the chart images first and try again"
        exit 2
    fi

    # Specific pulled docker images
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
fi


if [[ $selectedOpt = "3" || $selectedOpt = "4" ]]; then
    
    # Set default value for option 4 if not selected
    : ${releaseName:=""}
    : ${version_no:=""}


    install_tracker_file="$configDir/install_tracker" 
    installed=0

    if [ ! -f $install_tracker_file ]; then
        touch $install_tracker_file
    else
        # check if remote server exist in tracker file
        cat $install_tracker_file | grep -w $serverHost > /dev/null
        ec=$?
        if [ $ec -eq 0 ]; then #script already installed on server
            installed=1
        fi
    fi


    if [ $installed -eq 0 ]; then #script not installed on server
        echo "Initiating environment setup on remote server...."
        # Setup directories
        ssh -p $prt $pk $server_username@$serverHost "bash -s" < $init
        echo -e "Environment setup on remote server completed successfully....\n"

        # Copy remote source files to remote server
        echo "Initiating copying of remote source files to the remote server...."
        scp -pP $prt $pk -r $remote_src/* $server_username@$serverHost:$r_configsDir/ &&
        echo -e "Copied source files  successfully to the remote server\n" &&

        # mark as installed
        echo $serverHost >> $install_tracker_file
    fi

    echo "Initiating logging in to remote server, and marking of images for download..."
    ssh -tp $prt $pk $server_username@$serverHost sudo "$r_configsDir/markFiles.sh" $selectedOpt $image_list_file $releaseName $version_no && 
    echo -e "Image marking completed successfully\n"

    echo "Initiating image download from the remote server to local server...."
    scp -P $prt $pk -r $server_username@$serverHost:$dir/tempOutput/* $l_imageDir &&
    echo -e "All images has been downloaded successfully....\n"

fi