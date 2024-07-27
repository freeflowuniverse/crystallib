#!/bin/bash
set -ex

function my_function() {
    echo "In function"
    return 1
}

function my_function2() {
    #TODO: I don't want ls to stop here but not change the -e behavor of mother
    ls /sdsd
    if [ $? -ne 0 ]; then
        error_exit "ls does not workr."
        return 1
    fi    
}


echo "Before function call"
my_function2
echo "After function call - This will not be printed"