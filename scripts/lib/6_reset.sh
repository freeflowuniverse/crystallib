
function reset {
    if [[ -n "${FULLRESET}" ]]; then
        echo " - FULLRESET"
        rm -rf ~/.vmodules
        rm -rf ~/code  
        rm -rf $DONE_DIR
        mkdir -p  $DONE_DIR
    fi  

    if [[ -n "${RESET}" ]]; then
        echo " - RESET"
        rm -rf ~/.vmodules
        rm -rf $DONE_DIR
        mkdir -p  $DONE_DIR        
    fi  

}
