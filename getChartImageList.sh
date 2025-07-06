#!/bin/bash
read -p "Please specify the remote server host: " serverHost
read -p "Please specify the remote server username: " server_username
read -p "Please specify the remote server port, press Enter to use the default port (22): " serverPort
read -p "Please specify path to the priavte key if exist, to skip press ENTER: " privateKey
read -p "Enter the chartReference, example (zone/zonedependency): " chartRef
read -p "Enter the version number for helm chart: " version_no

releaseName=${chartRef//\//-}

# Remote directories
dir="/tmp/airGapTempFiles"
r_configsDir="$dir/configs"

# Set default port
[ ${#serverPort} -gt 0 ] && prt=$serverPort || prt="22"

# Set default private key
[ ${#privateKey} -gt 0 ] && pk="-i $privateKey" || pk=""

# Local directories and files
l_imageDir="./imgTemp"

# Remote directories
dir="/tmp/airGapTempFiles"
r_imageDir="$dir/images"
chartImageDir="$r_imageDir/$releaseName/$version_no"
fileName=${releaseName}_${version_no}"_temp_image_list.txt"
localName="$l_imageDir/$fileName"

echo "Initiating generation of chart image list on the remote server server...."
ssh -tp $prt $pk $server_username@$serverHost sudo "$r_configsDir/generateChartImageList.sh" $releaseName $version_no $chartRef && done=1

if [ $done -eq 1 ]; then
    echo -e "Chart image list generated successfully\n"
    echo "Initiating image list download from the remote server to local server...."
    scp -P $prt $pk -r $server_username@$serverHost:$chartImageDir/$fileName $localName
    echo -e "The image list has been downloaded successfully and saved as $localName"
fi