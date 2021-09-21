module imagemagick
import path
import process
import os

pub struct Image{
pub mut:	
	path path.Path
	size_x int
	size_y int
	resolution_x int
	resolution_y int
	size_kbyte int
}

pub fn image_new(path0 string) ?Image{
	mut p := path.Path{path:path0}
	mut i := Image{path:p}
	i.init()?
	return i
}

pub fn image_downsize(path0 string) ?{
	mut image := image_new(path0)?
	image.downsize("","")?
}


pub fn (mut image Image) init() ? {
	if image.size_kbyte == 0 {
		println(" - $image.path.path")
		image.size_kbyte = image.path.size_kb()
	}
}

pub fn (mut image Image) identify_verbose() ? {
	if image.size_y != 0 {
		//means was already done
		return
	}
	println(" - identify: $image.path.path")
	out := process.execute_silent("identify -verbose $image.path.path")or{
		return error("Could not get info from image, error:$err")
	}
	for line in out.split("\n"){
		mut line2:=line.trim(" ")
		if line2.starts_with("Geometry"){
			line2 = line2.all_before("+")
			line2 = line2.all_after(":").trim(" ")
			image.size_x = line2.split("x")[0].int()
			image.size_y = line2.split("x")[1].int()
		}
		if line2.starts_with("Resolution"){
			line2 = line2.all_after(":").trim(" ")
			image.resolution_x = line2.split("x")[0].int()
			image.resolution_y = line2.split("x")[1].int()
		}
	}
}
pub fn (mut image Image) identify() ? {
	if image.size_y != 0 {
		//means was already done
		return
	}
	println(" - identify: $image.path.path")
	mut out := process.execute_silent("identify -ping $image.path.path")or{		
		return error("Could not get info from image, error:$err")
	}
	out = out.trim(" \n")
	splitted := out.split(" ")
	size_str := splitted[2]
	if ! size_str.contains("x"){
		panic("error in parsing. $size_str")
	}
	image.size_x = size_str.split("x")[0].int()
	image.size_y = size_str.split("x")[1].int()
}

fn (mut image Image) is_png() bool {
	if image.path.extension().to_lower() == "png"{
		return true
	}
	return false
}

fn (mut image Image) skip() bool {
	if image.path.name_no_ext().ends_with("_"){
		return true
	}
	return false
}

//will downsize to reasonable size based on x
fn (mut image Image) downsize(sourcedir string, backupdir string) ? {
	image.init()?
	if image.skip(){
		return
	}
	if image.size_kbyte < 500 && ! image.is_png(){
		return
	}
	image.identify()?
	if backupdir != ""{
		mut dest := image.path.backup_name_find(sourcedir,backupdir)?
		image.path.copy(mut dest)?
	}

	if image.size_x > 2400{
		image.size_kbyte = 0
		process.execute_silent("convert ${image.path.path} -resize 50% ${image.path.path}")?
		// println(image)
		image.init()?

	}else if image.size_x > 1800{
		image.size_kbyte = 0
		process.execute_silent("convert ${image.path.path} -resize 75% ${image.path.path}")?
		image.init()?
	}

	if image.is_png() && image.size_kbyte > 500{
		path_dest := image.path.path_no_ext()+".jpg"
		println(" - convert to png")
		process.execute_silent("convert ${image.path.path} $path_dest")?
		if os.exists(path_dest){
			os.rm(image.path.path)?
		}
	}

}