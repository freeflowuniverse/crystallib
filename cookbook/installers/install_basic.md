## a basic installer

we first check the version of tailwind

this outputs

```bash
despiegk1@KDSPRO ~ % tailwind -h

tailwindcss v3.3.6

Usage:
   tailwindcss [--input input.css] [--output output.css] [--watch] [options...]
   tailwindcss init [--full] [--postcss] [options...]

Commands:
   init [options]

```

as you can see not trivial to parse, because we need to first fetch the line with tailwindcss v ...

texttools.version()

is a nice tool, it gets the version in int format

- v0.4.36 becomes 4036
- v1.4.36 becomes 1004036

```go

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.texttools
import os

pub fn install(args_ InstallArgs) ! {
	mut args := args_
    version:="3.3.6"

	res := os.execute('source ${osal.profile_path()} && tailwind -h')
	if res.exit_code == 0 {

        //filter out the line which has the version
		r:=res.output.split_into_lines().filter(it.contains("tailwindcss v"))
		if r.len != 1{
			return error("couldn't parse tailwind version, expected 'tailwindcss v' on 1 row.\n$res.output")
		}
        
        //is only 1 element get it, and we need all after the first space
		v:=texttools.version(r[0].all_after(" ")) 
		if v<texttools.version(version) { {
            //if lower than this nr if means we are expecting a higher nr, so we need to re-install
			args.reset = true
		}
	} else {
		args.reset = true
	}

	if args.reset == false {
		return
	}

	console.print_header('install tailwind')

	mut url := ''
	if osal.is_linux_arm() {
		url = 'https://github.com/tailwindlabs/tailwindcss/releases/download/v${version}/tailwindcss-linux-arm64'
	} else if osal.is_linux_intel() {
		url = 'https://github.com/tailwindlabs/tailwindcss/releases/download/v${version}/tailwindcss-linux-x64'		
	} else if osal.is_osx_arm() {
		url = 'https://github.com/tailwindlabs/tailwindcss/releases/download/v${version}/tailwindcss-macos-arm64'
	} else if osal.is_osx_intel() {
		url = 'https://github.com/tailwindlabs/tailwindcss/releases/download/v${version}/tailwindcss-macos-x64'
	} else {
		return error('unsported platform')
	}

	mut dest := osal.download(
		url: url
		minsize_kb: 40000
		// reset: true
	)!

    //the downloader is cool, it will check the download succeeds and also check the minimum size
	mut dest := osal.download(
		url: url
		minsize_kb: 40000
		// reset: true
	)!

	// println(dest)

    //the cmd_add adds tailwind to ~/hero/bin and makes sure ~/hero/bin is in our profile
	osal.cmd_add(
		cmdname: 'tailwind'
		source: dest.path
	)!

	return
}

```