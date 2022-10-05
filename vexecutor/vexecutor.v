module vexecutor

import freeflowuniverse.crystallib.pathlib

struct VExecutor{
	actions []VAction
}



struct VAction{
	path pathlib.Path
}


fn scan (mut path pathlib.Path)?{
	if ! path.exists(){
		return error("cannot find path: $path.path to scan for vlang files.")
	}
}


pub fn (mut action VAction) do()?{

}

pub fn (mut action VAction) do()?{

}