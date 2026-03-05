#!/bin/bash
source ../lib/progIdicator
read -p "Please specify the image name: " imageName

echo -e "Initiating image pruning for images with name '$imageName' .... \n"
showProgress "Prunning in progress"
success=0
failed=0

while read -r img; do
    if crictl rmi "$img" &> /dev/null; then
        echo "Deleted image: $img"
        success=$((success + 1))
    else
        echo "Failed to delete (likely in use): $img"
        failed=$((failed + 1))
    fi
done < <(crictl images | awk -v imageName="$imageName" '$1 ~ imageName {print $3}')
endProgress "Prunning  done!"  "s"
echo
echo "Summary:"
echo "Successful deletions: $success"

echo "Failed deletions: $failed"