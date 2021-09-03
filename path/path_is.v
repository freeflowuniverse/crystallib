module path

pub fn (mut path Path) is_dir() bool {
	if path.cat == Category.unknown {

	}
	return path.cat== Category.dir
}

pub fn (mut path Path) is_file() bool {
	return path.cat == Category.file
}

fn (mut path Path) check(){
	if os.exists(path){
		p2.exists = PathExists.yes
		if os.is_file(path.path){
			if os.is_link(path.path){
				path.cat = Category.linkfile
			}else{
				path.cat = Category.file
			}
		}else if os.is_dir(path){
			if os.is_link(path){
				path.cat = Category.linkdir
			}else{
				path.cat = Category.dir
			}
		}else{
			panic("cannot define type: $path.path")
		}		
	}else{
		p2.exists = PathExists.no
	}
}