#!/bin/bash

# Remote directories
dir="/tmp/airGapTempFiles"
trackDir="$dir/track"

# Recieve array list 
image_list=("$@")

read -p "Please specify the new host and repository (e.g. hostname[:port]/repository): " new_tag

for image in "${image_list[@]}"; do
    # check if images is downloaded aleady
    image_name=$(echo $image | cut -d'/' -f 3)
    safeName="${image_name//:/__}"
    e_image="$trackDir/$safeName.track"

    # newTagSeg=$(echo $new_tag | cut -d'/' -f )

    if [ -f $e_image ]; then
        # File exist
        echo -e "The image $image_name has been downloaded already\n"
    else

        host=$(echo $image | cut -d'/' -f 1)
        imageName=$(echo $image | cut -d'/' -f 2)

        # form new image name
        newName="$new_tag/$imageName"

        echo "Pulling image '$image'...."
        docker pull $image 2> "$dir/error"

        ec=$?

        if [ $ec -eq 0 ]; then
            echo -e "\nTagging image $image_name with $newName...."
            docker tag $image $newName 2> "$dir/error"

            ec=$?

            if [ $ec -eq 0 ]; then
                # Tagged successfully, proceed to pushing to local 
                echo -e "\nPushing $newName ...."
                docker push $newName 2> "$dir/error"

                ec=$?

                if [ $ec -eq 0 ];then
                    echo -e "Successfully pushed the image '$newName'\n"
                else
                    echo -e "The error below occured while pushin the image '$newName':\n "
                    cat "$dir/error"
                    echo -e "\n"
                fi

            else
                echo -e "The error below occured while tagging the image '$image' with '$newName'\n "
                cat "$dir/error"
                echo -e "\n"
            fi
            
        else
            echo -e "The error below occured while pulling the image '$image':\n "
            cat "$dir/error"
            echo -e "\n"
        fi

    fi
done