module tools

import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.installers.vscode

@[params]
pub struct InstallArgs {
pub mut:
	names string
	reset bool
}

pub fn install_multi(args_ InstallArgs)!{
	mut args:=args_
	mut items:=[]string{}
	for item in args.names.split(",").map(it.trim_space()){
		if ! (item in items){
			items<<item
		}
	}
	for item in items{

		match item {
			"vscode"{
				vscode.install(reset:args.reset)!
			}else{
			return error("cannot find installer for: $item")
			}
		}
	}
}
