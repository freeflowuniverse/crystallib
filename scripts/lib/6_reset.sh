
function reset {
    if [[ -z "${FULLRESET}" ]]; 
    then
        echo
    else
        rm -rf ~/.vmodules
        rm -rf ~/code  
    fi  

    if [[ -z "${RESET}" ]]; 
    then
        echo
    else
        rm -rf ~/.vmodules
    fi  

}
