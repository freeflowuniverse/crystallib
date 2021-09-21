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

pub fn (mut image Image) init() ? {
	println(" - $image.path.path")
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

	image.size_kbyte = image.path.size_kb()

}

fn (mut image Image) is_png() bool {
	if image.path.extension().to_lower() == "png"{
		return true
	}
	return false
}

//will downsize to reasonable size based on x
fn (mut image Image) downsize(sourcedir string, backupdir string) ? {
	if image.size_kbyte < 500{
		return
	}

	if backupdir != ""{
		mut dest := image.path.backup_name_find(sourcedir,backupdir)?
		image.path.copy(mut dest)?
	}

	if image.size_x > 2400{
		process.execute_silent("convert ${image.path.path} -resize 50% ${image.path.path}")?
		// println(image)

	}else if image.size_x > 1800{
		process.execute_silent("convert ${image.path.path} -resize 75% ${image.path.path}")?
	}

	if image.is_png(){
		path_dest := image.path.path_no_ext()+".jpg"
		process.execute_silent("convert ${image.path.path} $path_dest")?
		if os.exists(path_dest){
			os.rm(image.path.path)?
		}
	}

}