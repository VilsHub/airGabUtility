#!/bin/bash

read -p "Please specify the image name: " imageName

echo -e "Initiating image pruning for images with name '$imageName' .... \n"

crictl images | awk -v imageName="$imageName" '$1 ~ imageName {print $3}' | xargs -r crictl rmi &> /dev/null
ec=$?
n=0
if [ $ec -eq 0 ]; then
    n=$((n + 1)) 
fi

echo -e  "Done prunning $n images....."