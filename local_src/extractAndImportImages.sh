#!/bin/bash
PS3="Please select the target container runtime: "
runtimeType=("Containerd" "CRIO")
selectedOpt=0

select res in "${runtimeType[@]}"; do
    selectedOpt=$REPLY
    while [[ $REPLY != "1" && $REPLY != "2" ]]; do
        PS3="Please select a valid option for your container runtime: "
        select res in "${runtimeType[@]}"; do
            selectedOpt=$REPLY
            break
        done
    done
    break
done

if [ $selectedOpt = "2" ];then
    # Specify registry alias
    read -p "Please provide the full repository alias (e.g. myrepo.test:4000/v2): " r_alias
fi

read -p "Delete image file after importation? y/n: " d_image


# Local directories and files
l_imageDir="./imgTemp"
echo -e  "Initating extraction of downloaded images....\n"

downloadedImages=$(ls "$l_imageDir"/*.tar.gz 2> /dev/null)

if [ -n "$downloadedImages" ]; then
    for file in $downloadedImages; do
        imageName=$(basename $file)
        echo "Now extracting: $imageName"
        gunzip "$file"
    done
    echo -e "All downloaded files extracted successfully....\n"
else
    echo -e "No image found for extraction\n"
fi

extractedImages=$(ls "$l_imageDir"/*.tar 2> /dev/null)

if [ -n "$extractedImages" ]; then
    echo "Initiating Image import process...."
    for file in $extractedImages; do
        imageName=$(basename $file)

        if [ $selectedOpt = "1" ]; then
            # Containerd
            echo "Importing image: $imageName into containerd space"
            ctr -n=k8s.io images import "$file"

        else
            # CRIO
            # Remove the .tar extension
            basename="${file%.tar}"
            
            # Check if there is a colon (:) indicating a tag
            if [[ "$basename" == *__* ]]; then
                image="${basename%%__*}"
                tag="${basename#*__}"
            else
                image="$basename"
                tag="latest"
            fi

            # $image = ./imgTemp/imageName:tag
            image_name=$(echo $image | cut -d'/' -f 3)

            # skopeo copy docker-archive:$file "docker://$r_alias/$image_name:$tag"
            echo -e "\nCopying image '$image_name:$tag' to local registry...."
            docker run --rm --network=host -v $file:"/tmp/${image_name}_$tag.tar" quay.io/skopeo/stable copy  --dest-tls-verify=false docker-archive:"/tmp/${image_name}_$tag.tar" docker://$r_alias/$image_name:$tag
            
            echo -e "\nPulling image '$image_name:$tag' from registry to CRIO space...."
            crictl pull "$r_alias/$image_name:$tag"
        fi

        #Delete the tar ball after import
        if [[ $d_image = "y" || $d_image = "Y" ]]; then
            rm -f "$file"
        fi
        echo -e "\n"

    done

    echo -e  "All images imported successfully....\n"
fi
