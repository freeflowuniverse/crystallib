module golang

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.texttools
import os

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

// install golang will return true if it was already installed
pub fn install(args_ InstallArgs) ! {
	version := '1.21.6'

	mut args := args_
	res := os.execute('go version')
	if res.exit_code == 0 {
		r := res.output.split_into_lines()
			.filter(it.contains('go version'))

		if r.len != 1 {
			return error("couldn't parse go version, expected 'go version' on 1 row.\n${res.output}")
		}

		mut vstring := r[0] or { panic('bug') }
		vstring = vstring.all_after_first('version go').all_before(' ').trim_space()
		v := texttools.version(vstring)
		if v < texttools.version(version) {
			args.reset = true
		}
	} else {
		args.reset = true
	}

	if args.reset == false {
		return
	}

	console.print_header('install golang')

	// make sure we install base on the node
	base.install()!

	mut url := ''
	if osal.is_linux_arm() {
		url = 'https://go.dev/dl/go${version}.limux-arm64.tar.gz'
	} else if osal.is_linux_intel() {
		url = 'https://go.dev/dl/go${version}.linux-amd64.tar.gz'
	} else if osal.is_osx_arm() {
		url = 'https://go.dev/dl/go${version}.darwin-arm64.tar.gz'
	} else if osal.is_osx_intel() {
		url = 'https://go.dev/dl/go${version}.darwin-amd64.tar.gz'
	} else {
		return error('unsupported platform')
	}

	expand_dir := '/tmp/golang'

	// the downloader is cool, it will check the download succeeds and also check the minimum size
	mut dest := osal.download(
		url: url
		minsize_kb: 40000
		expand_dir: expand_dir
	)!

	mut go_dest := '/usr/local/go'
	if os.exists(go_dest) {
		os.rmdir_all(go_dest) or {
			return error('could be I have no permission to delete old go install,\ndo: sudo rm -rf /usr/local/go')
		}
	}
	go_dest = '${osal.usr_local_path()!}/go'
	os.mv('${expand_dir}/go', go_dest)!
	os.rmdir_all(expand_dir)!

	osal.profile_path_add(path: '${go_dest}/bin', todelete: 'go/bin')!
}
