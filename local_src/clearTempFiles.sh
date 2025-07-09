#!/bin/bash
# Get the cleanup type
cleanUpType=("Entire airGab temp files" "Specific Chart temp files")
PS3="Please select the type of clean up you wish to perform: "
selectedOpt=0
chart_name=""
target=""
select res in "${cleanUpType[@]}"; do
    selectedOpt=$REPLY
    while [[ $REPLY != "1" && $REPLY != "2" ]]; do
        PS3="Please select a valid option for the clean up type: "
        select res in "${cleanUpType[@]}"; do
            selectedOpt=$REPLY
            break
        done
    done
    break
done

clear="./local_src/clear.sh"

read -p "Please specify the remote server host: " serverHost
read -p "Please specify the remote server username: " server_username
read -p "Please specify the remote server port, press Enter to use the default port (22): " serverPort
read -p "Please specify path to the private key if exist, to skip press ENTER: " privateKey

if [ $selectedOpt = "2" ]; then
    read -p "Which chart would you like to clean up temp files for: " chart_name
    target="for the $chart_name chart"
fi

# Set default port
[ ${#serverPort} -gt 0 ] && prt=$serverPort || prt="22"

# Set default private key
[ ${#privateKey} -gt 0 ] && pk="-i $privateKey" || pk=""

echo "Initiating deletion of the airGab temp directory $target on the remote server...."
ssh -p $prt $pk $server_username@$serverHost "bash -s" < $clear $selectedOpt $chart_name

if [ $selectedOpt = "2" ]; then
    echo -e "The temp files for the $chart_name chart has been cleared successfully\n"
else
    echo -e "airGab temp directory deleted successfully on the remote server\n"
fi