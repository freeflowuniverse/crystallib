module postgresql

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
//import freeflowuniverse.crystallib.osal.systemd


import os


// checks if a certain version or above is installed
fn installed() !bool {
    //THIS IS EXAMPLE CODEAND NEEDS TO BE CHANGED
    // res := os.execute('${osal.profile_path_source_and()} postgresql version')
    // if res.exit_code != 0 {
    //     return false
    // }
    // r := res.output.split_into_lines().filter(it.trim_space().len > 0)
    // if r.len != 1 {
    //     return error("couldn't parse postgresql version.\n${res.output}")
    // }
    // if texttools.version(version) > texttools.version(r[0]) {
    //     return false
    // }
    return false
}

fn install() ! {
    //console.print_header('install postgresql')
    //mut cfg := get()!
}


fn startupcmd () ![]zinit.ZProcessNewArgs{
    mut res := []zinit.ZProcessNewArgs{}
	// cmd := "bash -c \"
	// cd ${cfg.path}
	// docker compose up 
	// \""    

    res << zinit.ZProcessNewArgs{
        name: 'postgresql'
        cmd: 'docker compose up'
        cmd_stop: 'docker compose down'
        env: {
            'HOME': cfg.path
        }    
    }

    return res
    
}

fn running() !bool {
    mut mydb := get()!
    mydb.check() or {return false}
    return true
}

fn start_pre()!{
    
}

fn start_post()!{
    
}

fn stop_pre()!{
    
}

fn stop_post()!{
    
}



fn destroy() ! {
    c := '

    #dont die
    set +e

    # Stop the PostgreSQL service
    sudo systemctl stop postgresql

    # Purge PostgreSQL packages
    sudo apt-get purge -y postgresql* pgdg-keyring

    # Remove all data and configurations
    sudo rm -rf /etc/postgresql/
    sudo rm -rf /etc/postgresql-common/
    sudo rm -rf /var/lib/postgresql/
    sudo userdel -r postgres
    sudo groupdel postgres

    # Remove systemd service files
    sudo rm -f /etc/systemd/system/multi-user.target.wants/postgresql
    sudo rm -f /lib/systemd/system/postgresql.service
    sudo rm -f /lib/systemd/system/postgresql@.service

    # Reload systemd configurations and reset failed systemd entries
    sudo systemctl daemon-reload
    sudo systemctl reset-failed

    echo "PostgreSQL has been removed completely"

    '
    osal.exec(cmd: c)!
}


