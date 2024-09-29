module griddriver

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console

import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.installers
import freeflowuniverse.crystallib.installers.lang.golang


// checks if a certain version or above is installed
fn installed() !bool {
    //THIS IS EXAMPLE CODEAND NEEDS TO BE CHANGED
    // res := os.execute('${osal.profile_path_source_and()} griddriver version')
    // if res.exit_code != 0 {
    //     return false
    // }
    // r := res.output.split_into_lines().filter(it.trim_space().len > 0)
    // if r.len != 1 {
    //     return error("couldn't parse griddriver version.\n${res.output}")
    // }
    // if texttools.version(version) > texttools.version(r[0]) {
    //     return false
    // }
    return false
}

fn install() ! {
    console.print_header('install griddriver')
	golang.install()!

	path := gittools.code_get(
		url: 'https://github.com/threefoldtech/web3gw/tree/development_integration/griddriver'
        branch:'development_integration'
		reset: true
		pull: true
	)!
	cmd := '
	set -ex
	cd ${path}
	go env -w CGO_ENABLED="0"
	go build -o ${path}/griddriver/bin/griddriver
	echo build ok
	'
	osal.execute_stdout(cmd)!
	osal.cmd_add(
		cmdname: 'griddriver'
		source: '${path}/griddriver/bin/griddriver'
	)!

	console.print_header('build griddriver OK')
}


fn build() ! {
    //mut installer := get()!
    //url := 'https://github.com/threefoldtech/griddriver'

    // make sure we install base on the node
    // if osal.platform() != .ubuntu {
    //     return error('only support ubuntu for now')
    // }
    // golang.install()!

    // console.print_header('build griddriver')

    // gitpath := gittools.code_get(coderoot: '/tmp/builder', url: url, reset: true, pull: true)!

    // cmd := '
    // cd ${gitpath}
    // source ~/.cargo/env
    // exit 1 #todo
    // '
    // osal.execute_stdout(cmd)!
    //
    // //now copy to the default bin path
    // mut binpath := dest.file_get('...')!
    // adds it to path
    // osal.cmd_add(
    //     cmdname: 'griddriver2'
    //     source: binpath.path
    // )!   

}

//get the Upload List of the files
fn ulist() !installers.UList {
    //mut installer := get()!
    //optionally build a UList which is all paths which are result of building, is then used e.g. in upload
    return installers.UList{}
}

//uploads to S3 server if configured
fn upload() ! {
    //mut installer := get()!
    // installers.upload(
    //     cmdname: 'griddriver'
    //     source: '${gitpath}/target/x86_64-unknown-linux-musl/release/griddriver'
    // )!

}




fn destroy() ! {
    //mut installer := get()!    
    // cmd:="
    //     systemctl disable griddriver_scheduler.service
    //     systemctl disable griddriver.service
    //     systemctl stop griddriver_scheduler.service
    //     systemctl stop griddriver.service

    //     systemctl list-unit-files | grep griddriver

    //     pkill -9 -f griddriver

    //     ps aux | grep griddriver

    //     "
    
    // osal.exec(cmd: cmd, stdout:true, debug: false)!
}

