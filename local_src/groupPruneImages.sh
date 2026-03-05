#!/bin/bash

read -p "Please specify the image name: " imageName

echo -e "Initiating image pruning for images with name '$imageName' .... \n"
totalImages=$(crictl images | grep "$imageName" |  wc -l)
crictl images | awk -v imageName="$imageName" '$1 ~ imageName {print $3}' | xargs -r crictl rmi
echo -e  "Done prunning images....."