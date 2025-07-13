#!/bin/bash
# Get the download type
PS3="Please select ypur desired task: "
taskType=("Setup local registry" "Uninstall local registry" "Check local registry status" "Start local registry" "Stop local registry")
selectedOpt=0

select res in "${taskType[@]}"; do
    selectedOpt=$(($REPLY))
    while [[ $selectedOpt -lt 1 ||  $selectedOpt -gt 5 ]]; do
        echo -e "\n"
        PS3="Please select a valid option for the task type: "
        select res in "${taskType[@]}"; do
            selectedOpt=$REPLY
            break
        done
    done
    echo $selectedOpt
    break
done

echo -e "\n"

# __________________functions start______________
function startLocalregistry(){
    read -p "Which port would you like the local registry to run on: " localPort

    echo -e "\n Starting local registry on port $localPort\n"
    docker run -d -p $localPort:5000 --name AirGab-LocalRegistry registry:2
}
function createPathIfNotExist() {
    if [ ! -d $1 ]; then
        mkdir -p $1
    fi
}

function confirmPath(){
    # args: 1 => file, 2 => file length (if = 0, then no file passed), 3 => optional, could be 0 or 1

    file="$1" 
    fileLength="$2"
    optional="$3" 

    shift 3  # Remove first 3 args
    prompt=("$@")  # Capture the passed prompt

    if [[ $optional -eq 1 && $fileLength -ne 0 ]]; then

        # # Check if file exist
        if [ ! -f "$file" ]; then
            found=0
            while [ $found -eq 0 ]; do
                read -p "The file '$file' ${prompt[@]}" image_list_file
                file=$image_list_file
                if [ -z $image_list_file ]; then
                    found=1
                elif [[ ! -z $image_list_file && -f "$image_list_file" ]]; then
                    found=1
                fi  
            done
        fi

    elif [ $optional -eq 0 ]; then

        # # Check if file exist
        if [ ! -f "$file" ]; then
            found=0
            while [ $found -eq 0 ]; do
                read -p "The file '$file' ${prompt[@]}"  image_list_file
                file=$image_list_file
                if [ -f "$image_list_file" ]; then
                    found=1
                fi
            done
        fi

    fi
    
}
# __________________functions end________________


# Compute OS family
if [ -f /etc/os-release ]; then
    source /etc/os-release
    OS_NAME=$NAME
    VERSION=$VERSION_ID
    DISTRO=$ID
fi

pm=""
osFamily=""
case "$DISTRO" in
    ubuntu|debian)
        osFamily="debian"
        pm="apt"
    ;;
    centos|rhel)
        osFamily="redhat"
        pm="yum"
    ;;
    fedora)
        osFamily="fedora"
        pm="dnf"
    ;;
    opensuse)
        osFamily="opensuse"
        pm="zypper"
    ;;
    *)
    echo "Unsupported OS: $ID"
    exit 1
    ;;
esac

if [ $selectedOpt = "1" ]; then
    # Setup local registry for crio
    read -p "Please provide the path to the local registry tar ball (.tar/.tar.gz) or press ENTER to skipped if you already have the 'registry:2' image pulled: " l_registry

    # Check if provided
    if [ ${#l_registry} -gt 0 ]; then
        
        prompt="does not exist, please specify a valid tar ball (.tar/.tar.gz) of the local registry, or press ENTER to skipped if you already have the 'registry:2' image pulled: "
        confirmPath "$l_registry" ${#l_registry} 1 "$prompt"

    fi


    read -p "Please provide the path to the skopeo tar ball: " skopeo
    prompt="The file '$skopeo' does not exist, please specify a valid tar ball of skopeo: "

    # Check if provided
    if [ ${#skopeo} -gt 0 ]; then
        
        prompt="The file '$skopeo' does not exist, please specify a valid tar ball (.tar/.tar.gz) of skopeo, or press ENTER to skipped if you already have the skopeo image pulled: "
        confirmPath "$skopeo" ${#skopeo} 1 "$prompt"

    fi


    read -p "Please provide the repository alias without the port (e.g. myrepo.test.io): " r_alias
    read -p "Please provide the target port that local registry will listen on: " r_port

    echo "Pre-flight check....."
    # check for gz
    if [[ "$l_registry" == *.tar.gz ]]; then
        gunzip "$l_registry"

        # Set new file path
        l_registry="${l_registry%.gz}"
    fi

    if [[ "$skopeo" == *.tar.gz ]]; then
        gunzip "$skopeo"

        # Set new file path
        skopeo="${skopeo%.gz}"
    fi

    # load local registry image
    echo -e "\nLocal registry setup.....1/3"
    docker load -i $l_registry 2> $(pwd)/err

    ec=$?

    if [ $ec -eq 0 ]; then
        echo -e "Local registry loaded successfully...\n"
         # Set insecure registry
        echo -e "Setting CRIO to allow local insecure registry.....2/3"

        createPathIfNotExist "/etc/containers/registries.conf.d"

        # Load the skopeo image
        echo -e "\nSkopeo setup.....3/3"
        docker load -i $skopeo 2> $(pwd)/err

        ec=$?

        if [ $ec -eq 0 ]; then
            echo -e "Skopeo loaded successfully...\n"

            echo -e "[[registry]]\nlocation = \"$r_alias:$r_port\"\ninsecure = true" > /etc/containers/registries.conf.d/99-airgab-insecure.conf
            systemctl restart crio 2> /dev/null

            read -p "Would you like to start the registry now (Y/N)?: " startReg
        
            if [[ $startReg = "y" || $startReg = "Y" ]]; then
                startLocalregistry
            fi
        else
            echo "Error occured while loading the image '$skopeo' Error: "
            cat $(pwd)/err
        fi
        
    else
        echo "Error occured while loading the image '$l_registry' Error: "
        cat $(pwd)/err
    fi

elif [ $selectedOpt = "2" ]; then
    echo -e "\nUninstalling local registry...."
    docker stop AirGab-LocalRegistry
    docker rmi registry:2
elif [ $selectedOpt = "3" ]; then
    echo -e "\nChecking local registry state...."
    docker ps | grep AirGab-LocalRegistry > /dev/null
    ec=$?

    if [ $ec -eq 0 ]; then
        echo -e "\nLocal registry is running...."
    else
        echo -e "\nLocal registry is not running...."
    fi

elif [ $selectedOpt = "4" ]; then
    echo -e "\nStarting local registry ...."
    docker image ls | grep -w registry > /dev/null
    ec=$?

    if [ $ec -eq 0 ]; then
        startLocalregistry
    else
        echo -e "\nLocal registry not setup exiting..."
    fi
elif [ $selectedOpt = "5" ]; then
    echo -e "\nStopping local registry ...."
    docker ps | grep AirGab-LocalRegistry > /dev/null
    ec=$?

    if [ $ec -eq 0 ]; then
        docket stop AirGab-LocalRegistry
    else
        echo -e "\nLocal registry not running..."
    fi
fi