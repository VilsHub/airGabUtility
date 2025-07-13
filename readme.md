# Overview 
The Airgab scripts helps in downloading bulk images via a server that has access to the internet or private image registry, and imports the images to a server without access to the internet.

# Script functions
Here are the functionalities included in the script:

 - Images downloads
 - Retrieving all images in a particular chart
 - Image extract and importation into containerd and CRIO scope
 - Setting up of local registry for CRIO
 - Retagging image from public repo to private repo

# Script requirements
  
  - Access to a proxy server
  - The followings softwares are required to be installed on the remote server:

     - Docker  : Needed for pulling docker images
     - Helm    : Needed for retrieving images in a specific helm chart
  
# Script installation

To install the script take the following steps:

  1. Make the **run.sh** file and all the **.sh** files in the **./local_src** and **./remote_src** directory excutable for all
   
      ```bash
        chmod a+x ./local_src/*.sh && chmod a+x ./remote_src/*.sh && chmod a+x ./run.sh
      ```

  2. Initialize the script to setup script on the target remote server. This is needed for image related operation

**Note**
- Ensure to make the scripts in the directory ./remote_src/ executable for all before initiating script on remote server to avoid the error below:
  
  **Error: sudo: /tmp/airGapTempFiles/configs/xxxxx.sh: command not found**
   

# Guides

## How to download an Image 

You can either download docker images from a list in a supplied file, or from a specified helm chart version.

### From list

To download docker images from list, take the steps below:

  1. Execute the **run.sh** script 
  2. Select option **2** "*Download Images*"
  3. Select option **1** "*Docker images from file*"
  4. Follow the prompt to supply the SSH credentials of the proxy server
  5. Supply the path to the file (which is expected to hold the list of images on each new line in the format: *hostname/repository/imageName:tag*). To get list of images See [Chart Image list generation](#how-to-generate-image-list)
  6. Wait for download operation to complete, once done you may be asked for your SSH password multiple times for task execution, but this depends on the remote server SSH configuration. On the last task, which would downloading of images to local server, you may choose to proceed on this stage or continue later using the **Download pulled images feature**. 

### From Helm chart

To download docker images from a helm chart (needed in a case where there is no image list), take the steps below:
  
  1. Execute the **run.sh** script 
  2. Select option **2** "*Download Images*"
  3. Select option **2** "*Docker images from helm Chart*"
  4. Follow the prompt to supply the SSH credentials of the proxy server
  5. Supply the chart reference, example (*projectName/chartName*) and the chart version on prompt
  6. Wait for download operation to complete, once done you may be asked for your SSH password multiple times for task execution, but this depends on the remote server SSH configuration. On the last task, which would downloading of images to local server, you may choose to proceed on this stage or continue later using the **Download pulled images feature**. 

**Note**
- If connectivity is broken, during the image pull process on the remote, the process will always resume from where it stopped on resumption 
- All downloaded images are compressed in **.tar.gz** format
- For chart images, the list of all the images would always be downloaded and stored in the directory **./imgTemp/[chartRefernce]_[version]_image_list.txt**. In a case where its fails to download due to connectivity, make use of the script **getChartImageList.sh** to get the image list.

## How to download pulled images 

This is needed in the case of internet disconnection, where you would only need to specify the list of images that are needed, or download all if needed. To download already pulled and compressed images from the remote server to the host system, take the step below:

  1. Execute the **run.sh** script
  2. Select option **3** "*Get pulled Images*" 
  3. This will prompt you to select the type of pulled images to download. The pulled images type are:
 
       - **All docker images**              : This will download all the pulled imaged on the remote server
       - **All pulled chart images**        : This will download all the images of a specified chart
       - **Specific pulled docker images**  : This will download all the docker images specified in the specified text file
       - **Specific pulled chart images**   : This will download all the chart images specified in the specified text file
  
  4. Follow the prompt to supply the SSH credentials of the proxy server.
  5. For specific pulled images download, you will be prompted to type in the file (which is expected to hold the list of images on each new line in the format: *hostname/repository/imageName:tag*) path of the image list.
  6. Once done, you may be asked for your SSH password multiple times for task execution, but this depends on the remote server SSH configuration.
  

## How to generate image list

To generate a list of images from a specified chart version, take the steps below:

  1. Execute the **run.sh** script 
  2. Select option **5** "*Get chart image list*"
  3. Depending on the environment to retrieve the image list from, select *1* for "*Local Server*" and *2* for "*Remote Server*" on prompt
  4. For *Local Server*, supply the chart reference, example (*projectName/chartName*) and the chart version on prompt. While for "*Remote Server*" follow the prompt to supply the SSH credentials of the proxy server and then supply the chart reference, example (*projectName/chartName*) and the chart version on prompt
  5. Wait for the image list generation operation to complete, once done you may be asked for your SSH password get the list to your local server, which would be store in the path: **./imgTemp/projectName-chartName_versionNumber_temp_image_list.txt**


## How to import the downloaded images
Image importation could be done for CRIO container runtime or Containerd container runtime.

### Containerd container runtime
To import the downloaded images into the **Containerd** scope, take the steps below:

  1. Ensure that all needed images have been downloaded and stored in **./imgTemp** directory
  2. Execute the **run.sh** script 
  3. Select option **4** "*Extract and import images*". This will prompt you to select your target container runtime
  4. Select option **1** "*Containerd*". This will prompt you if you would like to delete the images on successfull importation. All the images in the **./imgTemp** directory will be imported
  5. After the prompt, wait for the images to be extracted, and imported into the **Containerd** scope

### CRIO container runtime
To import the downloaded images into the **CRIO** scope, take the steps below:

  1. Ensure that all needed images have been downloaded and stored in **./imgTemp** directory
  2. Ensure that the local registry is setup. See [setting up a local registry](#how-to-setup-local-registry)
  3. Ensure that the local registry is running. See [starting a local registry](#how-to-start-local-registry)
  4. Execute the **run.sh** script 
  5. Select option **4** "*Extract and import images*". This will prompt you to select your target container runtime
  6. Select option **2** "*CRIO*". This will prmpt you to supply the full repository alias (e.g. myrepo.test:4000/v2). That is the DNS[:PORT]/repository. The DNS is that which was supplied during the local registry setup.
  7. Choose if you would like to delete the images on successfull importation on prompt. All the images in the **./imgTemp** directory will be imported
  8. After the prompt, wait for the images to be extracted, and imported into the **CRIO** scope

## How to setup local registry
This is needed to import images into CRIO containerd scope, as CRIO does not natively support image importation. To setup the local registry, take the steps below:

  1. Goto ./config/skopeo-link.txt and copy and download the skopeo tar.gz ball into the server, skip this step if you already have skopeo image loaded on docker on your local server where CRIO is running as the container runtime
  2. By default the script comes with a 'registry:2' image tar.gz ball, located in **./config/registry.tar.gz** which will be needed in the setup
  3. Execute the **run.sh** script 
  4. Select option **8** "*Manage local registry for CRIO*". This will prompt you for sub tasks selection
  5. Select option **1** "*Setup local registry*". This will prompt you to supply the path to the registry tar.gz ball and skopeo
  6. Supply the path to both, or skip with ENTER, if you already have the them pulled
  7. Supply the repository alias without the port (e.g. the DNS setup for a private image registry) on prompt. This will be needed during extraction and importation operation.
  8. Supply the port where the local registry should listen
  9. Wait for completion, once done you would be prompted to start the registry, which you could choose to do later on
 
## How to start local registry
To start a local registry after setting up, take the steps below:

  1. Ensure that the local registry is setup. See [setting up a local registry](#how-to-setup-local-registry)
  2. Execute the **run.sh** script
  3. Select option **8** "*Manage local registry for CRIO*". This will prompt you for sub tasks selection
  4. Select option **4** "*Setup local registry*". This will prompt you to select the port which the local registry is running on
  5. Supply the port which the local registry is running on

## How to Pull, Tag and Push Images
This is the process of pulling images from one registry (e.g ACR) followed by tagging of the image with the DNS of a local image registry, and then push to the private image registry (a local project).

This is needed in a case where Server **A** host a private image registry, and has access to another registry (e.g ACR) over the internet. And Server **B** has access to Server **A's** private image registry but not a public registry like ACR.

TO carry out this operation take the steps below, using Server A and Server B (The airGap server) as an example:

  1. Setup Docker Authentication for both public and private registry on Server A
  2. Setup a local DNS mapping for the local registry if no public DNS server
  3. In server B, execute the **run.sh** script
  4. Select option **9** "*Pull, Tag and Push Images*". This will prompt you for the file which contains the names (in the format: **hostname/repository/imageName:tag**) of the images to be pulled and tagged.
  5. Supply the file path. This will prompt you for the new tag to be used for tagging, which should be of the format: **hostname[:port]/repository** where *hostname* is the DNS supplied in step **2**
  6. Wait for process to complete

## How to clear temp directory on remote server
To clear the temp directory on a target remote server, take the steps below:

  1. Execute the **run.sh** script 
  2. Select option **5** "*Get chart image list*"
  3. Execute the **clearTempFiles.sh** script.
  4. Select the clean up type to be performed. This could either be a selective clean up of chart temp files or the entire airGab temp directory
  5. Follow the prompt to supply the SSH credentials of the proxy server, and wait for the clean up to be completed.