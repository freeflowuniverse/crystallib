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


//combine all found actions into 1 big compile step
pub fn (mut action VAction) combine()?{

}

pub fn (mut action VAction) do()?{

}