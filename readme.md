# Overview 
The Airgab scripts helps in downloading images via a server that has access to the internet or private image registry, and imports the images to a server without access to the internet.

# Script functions
The available scripts are:

 - clearTempFiles.sh
 - downloadImages.sh
 - downloadPulledImages.sh
 - extractAndImportImages.sh
 - getChartImageList.sh

## clearTempFiles.sh
This script is used to clear dowwnload images or the entire airgab temp directory. The temp directory would be located at **/tmp/airGapTempFiles** on the target remote server


## downloadImages.sh
This script is used to download, docker images and chart Images. It would first pull and store the desired images on the target remote server, then downloads them to the local server. The downloaded images would be stored on the local server at **./imgTemp**


## downloadPulledImages.sh
This script is used to download images that has already been pulled and stored on the remote server. This is needed in the case of internet disconnection, where you would only need to specify the list of images that are needed, or download all if needed.

## extractAndImportImages.sh
This script is used to extract and import the the downloaded image to **ctr** scope

## getChartImageList.sh
This script is used to get the list of images for a Helm chart 

# Using scripts

## How to download images
To download images, take the following steps:

 1. Make all the .sh files executalbe and make the scripts in the **./local_src/** directory executable for all users (**chmod a+x ./local_scr/*.sh**)
   
 2. Execute the **downloadImages.sh** script. This will prompt you to select to select the type of images to be downloaded, which could either be **Docker images**, or **Chart images**.
   
 3. Follow the prompt to supply the SSH credentials of the proxy server.
   
 4. For docker image download you, would be asked to supply the name of the file which is expected to hold the list of images on each new line. But chart images, you would be asked the followings:
   
      - The chart reference of the helm chart. Example zone/zone
      - The version number for helm chart. Example 1.0.202

 5. Once done, you may be asked for your SSH password multiple for task execution, but this depends on the remote server SSH configuration. On the last task, which would downloading of images to local server, you may choose to proceed on this stage or continue later using the **downloadPulledImages.sh** script

**Note**
- If connectivity is broken, during the image pull process on the remote, the process will always resume from where it stopped on resumption 
- All downloaded images are compressed in **.tar.gz** format
- For chart images, the list of all the images would always be downloaded and stored in the directory **./imgTemp/[releaseName]_[version]_image_list.txt**. In a case where its fails to download due to connectivity, make use of the script **getChartImageList.sh** to get the image list.
- Ensure to make the script ./remote_src/downloadAndCompressImages.sh executable for all before initiating download on remote server to avoid the error below:
  
  **Error: sudo: /tmp/airGapTempFiles/configs/downloadAndCompressImages.sh: command not found**

## How to import the downloaded images
To import the downloaded images into the *ctr* scope, take the steps below:

 1. Execute the **extractAndImportImages.sh** script. This will prompt you if you would like to delete the images on successfull importation. All the images in the **./imgTemp** directory will be imported

 2. After the prompt, wait for the images to be extracted, and imported into the **ctr** scope


## How to download pulled images
To download all or specific pulled images, take the steps below:
 1. If you wish to download some specific pulled images, add a text file of the image list **(each image on a new line)** in the directory **./configs**

 2. Execute the **downloadPulledImages.sh** script. This will prompt you to select the type of pulled images to download. The pulled images type are:
 
       - **All docker images**              : This will download all the pulled imaged on the remote server
       - **All pulled chart images**        : This will download all the images of a specified chart
       - **Specific pulled docker images**  : This will download all the docker images specified in the specified text file
       - **Specific pulled chart images**   : This will download all the chart images specified in the specified text file

 3. Follow the prompt to supply the SSH credentials of the proxy server.

 4. For specific pulled images download, you will be prompted to type in the file name of the text file, which contain the list of images to be downloaded.

 5. Once done, you may be asked for your SSH password multiple for task execution, but this depends on the remote server SSH configuration. 


## How to get chart image list
To get all the list of images that a helm chart makes use of, follow the step below:

 1. Execute the **getChartImageList.sh** script.
   
 2. Follow the prompt to supply the SSH credentials of the proxy server.

 3. Also, you would be prompted for the following below:
   
      - The name of the helm chart. Example zonedepenendecies
      - The version number for helm chart. Example 1.0.202

 4. Confirm from the next prompt that you have downloaded or pulled the chart images before, and supply your SSH pasword.

 
## How to clear temp directory on remote server
To clear the temp directory on a target remote server, take the steps below:

 1. Execute the **clearTempFiles.sh** script.

 2. Select the clean up type to be performed. This could either be a selective clean up of chart temp files or the entire airGab temp directory
 
 3. Follow the prompt to supply the SSH credentials of the proxy server, and wait for the clean up to be completed.


