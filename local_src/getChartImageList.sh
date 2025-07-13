#!/bin/bash

PS3="Please where to get the target chart image list: "
envType=("Local Server" "Remote Server")
selectedOpt=0

select res in "${envType[@]}"; do
    selectedOpt=$REPLY
    while [[ $REPLY != "1" && $REPLY != "2" ]]; do
        PS3="Please select a valid option for the environment to get the chart image list: "
        select res in "${envType[@]}"; do
            selectedOpt=$REPLY
            break
        done
    done
    break
done

if [ $selectedOpt = "2" ]; then
    read -p "Please specify the remote server host: " serverHost
    read -p "Please specify the remote server username: " server_username
    read -p "Please specify the remote server port, press Enter to use the default port (22): " serverPort
    read -p "Please specify path to the priavte key if exist, to skip press ENTER: " privateKey
fi

read -p "Enter the chartReference, i.e. (projectName/chartName): " chartRef
read -p "Enter the version number for helm chart: " version_no

targetChartRef=${chartRef//\//-}

if [ $selectedOpt = "2" ];then
  
    # Remote directories
    dir="/tmp/airGapTempFiles"
    r_imageDir="$dir/images"
    r_configsDir="$dir/configs"
    chartImageDir="$r_imageDir/$targetChartRef/$version_no"
    fileName=${targetChartRef}_${version_no}"_temp_image_list.txt"

    # Local directory
    l_imageDir="./imgTemp"
    localName="$l_imageDir/$fileName"

    # Set default port
    [ ${#serverPort} -gt 0 ] && prt=$serverPort || prt="22"

    # Set default private key
    [ ${#privateKey} -gt 0 ] && pk="-i $privateKey" || pk=""

    echo "Initiating generation of chart image list on the remote server server...."
    ssh -tp $prt $pk $server_username@$serverHost sudo "$r_configsDir/generateChartImageList.sh" $targetChartRef $version_no $chartRef "remote" && done=1

    if [ $done -eq 1 ]; then
        echo -e "Chart image list generated successfully\n"
        echo "Initiating image list download from the remote server to local server...."
        scp -P $prt $pk -r $server_username@$serverHost:$chartImageDir/$fileName $localName
        echo -e "The image list has been downloaded successfully and saved as $localName"
    fi

else

    # execute locally
    bash "./remote_src/generateChartImageList.sh" $targetChartRef $version_no $chartRef "local"  && done=1

fi

