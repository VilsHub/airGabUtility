#!/bin/bash

targetChartRef=$1 # combine chartReference to form the release name
chartReference=$3
versionNumber=$2
env=$4

# Store image list for reference
fileName=${targetChartRef}_${versionNumber}"_temp_image_list.txt"

if [ $env = "remote" ]; then
    # Remote directories
    dir="/tmp/airGapTempFiles"
    configsDir="$dir/configs"
    imageDir="$dir/images"

    chartImageDir="$imageDir/$targetChartRef/$versionNumber"

    if [ ! -d $chartImageDir ]; then
        # Directory does not exist
        mkdir -p $chartImageDir
        chmod a+wr $imageDir/$targetChartRef $imageDir/$targetChartRef/$versionNumber
    fi

    storeName=$chartImageDir/$fileName
else
    # Local env
    dir="/tmp"
    l_imageDir="./imgTemp"
    # localName="$l_imageDir/$fileName"
    
    storeName="$l_imageDir/$fileName"
fi


# Example targetChartRef=zone-dependendency, chartReference=zone/zone
echo "Updating helm repo and installing zone..."
helm repo update
helm template $targetChartRef $chartReference --version $versionNumber > "$dir/temp-values.txt" 

# Set permissions
chmod a+w "$dir/temp-values.txt"

# Step 3
echo -e "Extracting image values..."
grep -oP '(?<=image: ).*' $dir/temp-values.txt | sort | uniq > "$dir/temp-values-extract.txt"

tr -d '\r' < $dir/temp-values-extract.txt > $dir/temp-values-extract-unix.txt
mv $dir/temp-values-extract-unix.txt $dir/temp-values-extract.txt

# Set permissions
chmod a+w "$dir/temp-values-extract.txt"

cp -p "$dir/temp-values-extract.txt" $storeName

echo "All chart images list have been generated successfully..."