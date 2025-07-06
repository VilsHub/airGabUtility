#!/bin/bash

# Remote directories
dir="/tmp/airGapTempFiles"
configsDir="$dir/configs"
imageDir="$dir/images"

releaseName=$1
chartReference=$3
versionNumber=$2

chartImageDir="$imageDir/$releaseName/$versionNumber"

if [ ! -d $chartImageDir ]; then
    # Directory does not exist
    mkdir -p $chartImageDir
    chmod a+wr $imageDir/$releaseName $imageDir/$releaseName/$versionNumber
fi


# Example releaseName=zone-dependendency, chartReference=zone/zone

echo "Updating helm repo and installing zone..."
helm repo update
helm template $releaseName $chartReference --version $versionNumber > "$dir/temp-values.txt" 

# Set permissions
chmod a+w "$dir/temp-values.txt"

# Step 3
echo -e "Extracting image values..."
grep -oP '(?<=image: ).*' $dir/temp-values.txt | sort | uniq > "$dir/temp-values-extract.txt"

tr -d '\r' < $dir/temp-values-extract.txt > $dir/temp-values-extract-unix.txt
mv $dir/temp-values-extract-unix.txt $dir/temp-values-extract.txt

# Set permissions
chmod a+w "$dir/temp-values-extract.txt"

# Store image list for reference
fileName=${releaseName}_${versionNumber}"_temp_image_list.txt"
cp -p "$dir/temp-values-extract.txt" $chartImageDir/$fileName

echo "All chart imiages list have been generated successfully..."