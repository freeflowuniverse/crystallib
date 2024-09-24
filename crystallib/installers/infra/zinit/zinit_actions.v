module zinit

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.osal.zinit
import freeflowuniverse.crystallib.installers.ulist
import freeflowuniverse.crystallib.installers.lang.rust
import freeflowuniverse.crystallib.develop.gittools


import os


// checks if a certain version or above is installed
fn installed() !bool {
	cmd := 'zinit --version'
	// console.print_debug(cmd)
	res := os.execute(cmd)
	if res.exit_code == 0 {
		r := res.output.split_into_lines().filter(it.trim_space().starts_with('zinit v'))
		if r.len != 1 {
			return error("couldn't parse zinit version.\n${res.output}")
		}
		if texttools.version(version) == texttools.version(r[0].all_after_first('zinit v')) {			
			return true
		} 
    }
    console.print_debug(res.str())
	return false
}

fn install() ! {
    console.print_header('install zinit')
	if !osal.is_linux() {
		return error('only support linux for now')
	}

	release_url := 'https://github.com/threefoldtech/zinit/releases/download/v0.2.14/zinit'

	mut dest := osal.download(
		url: release_url
		minsize_kb: 2000
		reset: true
	)!

	osal.cmd_add(
		cmdname: 'zinit'
		source: dest.path
	)!

	osal.dir_ensure('/etc/zinit')!

	console.print_header('install zinit done')
}


fn build() ! {
	if !osal.is_linux() {
		return error('only support linux for now')
	}

	rust.install()!

	// install zinit if it was already done will return true
	console.print_header('build zinit')

	gitpath := gittools.code_get(coderoot: '/tmp/builder', url: 'https://github.com/threefoldtech/zinit', reset: true, pull: true)!

	// source ${osal.profile_path()}

	cmd := '
	source ~/.cargo/env
	cd ${gitpath}
	make release
	'
	osal.execute_stdout(cmd)!

	osal.cmd_add(
		cmdname: 'zinit'
		source: '/tmp/builder/github/threefoldtech/zinit/target/x86_64-unknown-linux-musl/release/zinit'
	)!

}

//get the Upload List of the files
fn ulist_get() !ulist.UList {
    return ulist.UList{}
}

//uploads to S3 server if configured
fn upload() ! {

}


fn startupcmd () ![]zinit.ZProcessNewArgs{
    mut res := []zinit.ZProcessNewArgs{}
    res << zinit.ZProcessNewArgs{
        name: 'zinit'
        cmd: '/usr/local/bin/zinit init'
        startuptype:.systemd
        restart:true
    }
    return res
    
}

fn running() !bool {
	cmd:='zinit list'
	return osal.execute_ok(cmd)

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
    //mut installer := get()!    
    // cmd:="
    //     systemctl disable zinit_scheduler.service
    //     systemctl disable zinit.service
    //     systemctl stop zinit_scheduler.service
    //     systemctl stop zinit.service

    //     systemctl list-unit-files | grep zinit

    //     pkill -9 -f zinit

    //     ps aux | grep zinit

    //     "
    
    // osal.exec(cmd: cmd, stdout:true, debug: false)!
}

