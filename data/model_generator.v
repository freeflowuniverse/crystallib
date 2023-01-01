module data
import freeflowuniverse.crystallib.pathlib

pub struct CodeGenerator{
pub mut:
	path_in pathlib.Path
	path_out pathlib.Path
	domains []&Domain
}

