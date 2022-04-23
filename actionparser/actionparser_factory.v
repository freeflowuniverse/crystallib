module actionparser
import os

pub fn init() Actions {
	return Actions{}
}

//path can be a directory or a file
pub fn (mut pr Actions) add(path string)?  {

	//recursive behavior for when dir
	if os.is_dir(path){
		mut items := os.ls(path)?
		items.sort() //make sure we sort the items before we go in
		//process dirs first, make sure we go deepest possible
		for path0 in items{
			if os.is_dir(path0){
				pr.add(path0)?
			}
		}
		//now process files in order
		for path1 in items{
			if os.is_file(path1) && path.to_lower().ends_with(".md"){
				pr.add(path1)?
			}
		}
	}		
	//make sure we only process markdown files
	if os.is_file(path) && path.to_lower().ends_with(".md") {
		pr.file_parse(path)
	}
}

