#!/bin/bash

# Remote directories
dir="/tmp/airGapTempFiles"
configsDir="$dir/configs"
imageDir="$dir/images"

releaseName=$1
chartReference=$3
versionNumber=$2

trackDir="$dir/track"
chartImageDir="$imageDir/$releaseName/$versionNumber"

if [ ! -d $chartImageDir ]; then
    # Directory does not exist
    mkdir -p $chartImageDir
    chmod a+wr $imageDir/$releaseName $imageDir/$releaseName/$versionNumber
fi

if [ ! -d $trackDir ]; then
    # Directory does not exist
    mkdir -p $trackDir
    chmod a+wr $trackDir
fi

# Example releaseName=zone_dependendency, chartReference=zone/zone

echo "Updating helm repo and installing zone..."
helm repo update
helm template $releaseName $chartReference --version $versionNumber > "$dir/zone-values.txt" 

# Set permissions
chmod a+w "$dir/zone-values.txt"

# Step 3
echo -e "Extracting image values..."
grep -oP '(?<=image: ).*' $dir/zone-values.txt | sort | uniq > "$dir/zone-values-extract.txt"

tr -d '\r' < $dir/zone-values-extract.txt > $dir/zone-values-extract-unix.txt
mv $dir/zone-values-extract-unix.txt $dir/zone-values-extract.txt

# Set permissions
chmod a+w "$dir/zone-values-extract.txt"

# Store image list for reference
cp -p "$dir/zone-values-extract.txt" $chartImageDir/$releaseName"_"$versionNumber"_image_list.txt"

# Download and compress images
echo -e "Initiating pulling and saving of docker images....\n"

if [ ! -f "$dir/error" ]; then
    # Create error file
    touch "$dir/error"
    chmod a+w "$dir/error"
fi


while read image; do
    # check if images is downloaded aleady
    image_name=$(echo $image | cut -d'/' -f 2)
    e_image="$trackDir/$releaseName"_"$versionNumber"_"$image_name.track"

    if [ -f $e_image ]; then
        # File exist
        echo -e "The image $image_name has been downloaded already\n"
    else
        echo "Pulling image $image"
        docker pull $image 2> "$dir/error"
        ec=$?

        if [ $ec -eq 0 ]; then
            echo "Saving image $image_name"
            docker save $image > "$chartImageDir/$image_name.tar" &&

            # Set permissions
            chmod a+w "$chartImageDir/$image_name.tar"

            echo "Compressing image $image_name"
            gzip "$chartImageDir/$image_name.tar" &&
            
            # Set permissions
            chmod a+w "$chartImageDir/$image_name.tar.gz"

            # track completely downloaded image
            touch $e_image

            # Set permissions
            chmod a+w $e_image

            echo -e "\n"
        else
            echo -e "The error below occured while pulling the image $image_name.\n "
            cat "$dir/error"
            echo -e "\n"
        fi

    fi
done < "$dir/zone-values-extract.txt"

echo "All images pulled, saved and compressed successfully..."