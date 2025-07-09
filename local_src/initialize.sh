#!/bin/bash

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


# Remote directories
dir="/tmp/airGapTempFiles"
r_configsDir="$dir/configs"
r_imageDir="$dir/images"
dockerImageOutputDir="$dir/tempOutput"

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
    ssh -p $prt $pk $server_username@$serverHost "bash -s" < $init &&
    echo -e "Environment setup on remote server completed successfully....\n"

    # Copy remote source files to remote server
    echo "Initiating copying of remote source files to the remote server...."
    scp -pP $prt $pk -r $remote_src/* $server_username@$serverHost:$r_configsDir/ &&
    echo -e "Copied source files  successfully to the remote server\n" &&

    # mark as installed
    echo $serverHost >> $install_tracker_file

else
    echo "Script has already been initialized on the target remote server...."
fi