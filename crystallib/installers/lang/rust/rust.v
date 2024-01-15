module rust

import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.installers.base

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

pub fn install(args_ InstallArgs) ! {
	mut args := args_
	res := os.execute('rustc -V')
	if res.exit_code == 0 {

		r:=res.output.split_into_lines()
			.filter(it.contains("rustc"))
			
		if r.len != 1{
			return error("couldn't parse rust version, expected 'rustc 1.' on 1 row.\n$res.output")
		}

		mut vstring:=r[0] or { panic("bug") }
		vstring=vstring.all_after_first(" ").all_before("(").trim_space()
		v:=texttools.version(vstring)
		if v<1007500 {
			args.reset = true
		}
	} else {
		args.reset = true
	}

	if args.reset == false {
		return
	}

	base.install()!

	// install rust if it was already done will return true
	console.print_header('start install rust')

	osal.execute_stdout("curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y")!

	osal.profile_path_add(path:'${os.home_dir()}/.cargo/bin')!

	return
}
