
function myplatform {
    if [[ "${OSTYPE}" == "darwin"* ]]; then
        export OSNAME='darwin'
    elif [ -e /etc/os-release ]; then
        # Read the ID field from the /etc/os-release file
        export OSNAME=$(grep '^ID=' /etc/os-release | cut -d= -f2)
        if [ "${os_id,,}" == "ubuntu" ]; then
            export OSNAME="ubuntu"          
        fi
        if [ "${OSNAME}" == "archarm" ]; then
            export OSNAME="arch"          
        fi        
    else
        echo "Unable to determine the operating system."
        exit 1        
    fi


    # if [ "$(uname -m)" == "x86_64" ]; then
    #     echo "This system is running a 64-bit processor."
    # else
    #     echo "This system is not running a 64-bit processor."
    #     exit 1
    # fi    

}

