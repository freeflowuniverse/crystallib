
import freeflowuniverse.crystallib.imagemagick { image_new, image_downsize }
import freeflowuniverse.crystallib.pathlib
import os

const testpath = os.dir(@FILE) + '/example'

// fn testsuite_begin() {
// 	os.rmdir_all(testpath) or {}
// 	assert !os.is_dir(testpath)
// 	os.mkdir_all(testpath) or {panic(err)}
// }

// fn testsuite_end() {
// 	os.rmdir_all(testpath) or {}
// }

fn test_image_downsize() {
	mut img_path := pathlib.get('$testpath/large_png.png')
	mut image := image_new(mut img_path) or {
		panic('Cannot get new image:\n $err')
	}
	image.init_() or {
		panic('Could not initialize image: $err')
	}
	assert image.size_kbyte > 600

	backup_dir := '$testpath/backup'
	mut downsized_img := image_downsize(mut img_path, backup_dir) or {
		panic('Cannot downsize image:\n $err')
	}

	// test correct file renaming
	assert downsized_img.size_kbyte < image.size_kbyte
	assert downsized_img.path.name_no_ext() == '${image.path.name_no_ext()}_'
	println(downsized_img.path.name())
}

// fn downsize_test() {
// 	img_path := pathlib.get('$testpath/small_png.png')
// 	image := image_new(img_path)
// }