module pathlib


// import freeflowuniverse.crystallib.ui.console




//get all text for path and underneith (works for dir & file)
pub fn (mut path Path) recursive_text() ![]string {
	mut res:=[]string{}
	path.check_exists()!
	// console.print_debug('recursive_text: $path.path")
	if path.cat == .file {
		c:=path.read()!
		res<<c.split_into_lines()		
	} else {
		mut pl := path.list(recursive: true)!
		for mut p in pl.paths {
			res << p.recursive_text()!
		}		
	}
	return res
}
