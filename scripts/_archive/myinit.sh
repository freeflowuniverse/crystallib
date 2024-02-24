

function myinit0 {

    myplatform

    if ! [[ -f "$HOME/.vmodules/done_init" ]]; then

        echo "do init"
        
        mkdir -p $HOME/.vmodules

        if [[ "$OSNAME" == "darwin" ]]; then 
            profile_file="$HOME/.zprofile"
            env_file="$HOME/env.sh"
            # Check if env.sh is already loaded in .profile
            if grep -q "source $env_file" "$profile_file"; then
                echo "env.sh is already loaded in .zprofile."
            else
                # Append the 'source' command to load env.sh in .profile
                echo "Adding 'source $env_file' to .zprofile..."
                echo "source $env_file" >> "$profile_file"
                echo "env.sh has been added to .zprofile."
            fi    
        else
            profile_file="$HOME/.profile"
            env_file="$HOME/env.sh"
            # Check if env.sh is already loaded in .profile
            if grep -q "source $env_file" "$profile_file"; then
                echo "env.sh is already loaded in .profile."
            else
                # Append the 'source' command to load env.sh in .profile
                echo "Adding 'source $env_file' to .profile..."
                echo "source $env_file" >> "$profile_file"
                echo "env.sh has been added to .profile."
            fi        
        fi

        package_install curl

        sshknownkeysadd

        touch "$HOME/.vmodules/done_init"

    fi    

}
