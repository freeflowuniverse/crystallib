import despiegk.crystallib.path

// fn test_file_new(){
// 	println('************ TEST_test_file_new ************')
// 	p:= path.file_new("/workspace/test_path/newfile1") or {panic(err)}
// 	assert p.exists == 2
// }

// fn test_file_new_empty(){
// 	println('************ TEST_test_file_new_empty ************')
// 	p:= path.file_new_empty("/workspace/test_path/newfile1") or {panic(err)}
// 	assert p.exists == 1
// 	println("New Empty file created successfully")
// }

// fn test_file_new_exists(){
// 	println('************ TEST_ ************')
// }

// fn test_dir_new(){
// 	println('************ TEST_ ************')

// }

// fn test_dir_new_empty(){
// 	println('************ TEST_ ************')
	
// }

// fn test_dir_new_exists(){
// 	println('************ TEST_ ************')

// }


// fn test_linkfile_new(){
// 	println('************ TEST_ ************')

// }

// fn test_linkfile_new_exists(){
// 	println('************ TEST_ ************')

// }

// fn test_linkdir_new(){
// 	println('************ TEST_ ************')

// }

// fn test_linkdir_new_exists(){
// 	println('************ TEST_ ************')

// }

// fn test_get(){
// 	println('************ TEST_Get ************')
// 	fp:= path.get("/workspace/test_path/newfile1") or {panic(err)}
// 	assert fp.cat == path.Category.file
// 	println("File Result: $fp")
// 	dp:= path.get("/workspace/test_path") or {panic(err)}
// 	assert dp.cat == path.Category.dir
// 	println("Dir Result: $dp")

// }

// fn test_exists(){
// 	println('************ TEST_exists ************')
// 	mut p1:= path.get("/workspace/test_path/newfile1") or {panic(err)}
// 	assert p1.exists()
// 	println("File found")
// 	mut p2:= path.file_new("/workspace/test_path/NotARealFile") or {panic(err)}
// 	assert ! p2.exists()
// 	println("File not found")
// }

// fn test_parent(){
// 	println('************ TEST_test_parent ************')
// 	mut test_path_dir := path.get("/workspace/test_path") or {panic(err)}
// 	mut p:= path.get("/workspace/test_path/newfile1") or {panic(err)}
// 	parent_dir:= p.parent() or {panic(err)}
// 	assert parent_dir == test_path_dir
// 	println("Parent Function working correctly")
// }

// fn test_parent_find() {
// 	println('************ TEST_test_parent_find ************')
// 	// - newfile1 is located in test_path
// 	// - will start search from test_parent that is inside test_path
// 	// - Result must be test_path
// 	mut test_path_dir := path.get("/workspace/test_path") or {panic(err)}
// 	mut p:= path.get("/workspace/test_path/test_parent") or {panic(err)}
// 	parent_dir:= p.parent_find("newfile1") or {panic(err)}
// 	assert parent_dir == test_path_dir.path
// 	println("Find Parent Function working correctly")

// }

// fn test_delete() {
// 	println('************ TEST_delete ************')
// 	mut test_path_dir := path.get("/workspace/test_path") or {panic(err)}
// 	mut p:= path.get("/workspace/test_path/linkdir1") or {panic(err)}
// 	p.delete() or {panic(err)}
// 	assert !test_path_dir.file_exists("linkdir1")
// 	println("File deleted successfully")
// }

// fn test_dir_exists(){
// 	println('************ TEST_dir_exists ************')
// 	mut test_path_dir := path.get("/workspace/test_path") or {panic(err)}
// 	assert test_path_dir.dir_exists("test_parent")
// 	println("test_parent found in $test_path_dir.path")

// 	assert ! test_path_dir.dir_exists("test_parent_2")
// 	println("test_paren_2 not found in $test_path_dir.path")
// }

// fn test_dir_find(){
// 	println('************ TEST_dir_find ************')
// 	mut test_path_dir := path.get("/workspace/test_path") or {panic(err)}
// 	mut test_parent_dir := test_path_dir.dir_find("test_parent") or {panic(err)}
// 	assert test_parent_dir.exists == 1
// 	println("Dir found: $test_parent_dir")

// 	// assert test_path_dir.dir_find("test_parent_2")
// 	// println("Dir test_parent_2 not found")

// }

// fn test_file_exists(){
// 	println('************ TEST_file_exists ************')
// 	mut test_path_dir := path.get("/workspace/test_path") or {panic(err)}
// 	assert test_path_dir.file_exists("newfile1")
// 	println("newfile1 found in $test_path_dir.path")

// 	assert ! test_path_dir.file_exists("newfile2")
// 	println("newfile2 not found in $test_path_dir.path")
// }

// fn test_file_find(){
// 	println('************ TEST_file_find ************')
// 	mut test_path_dir := path.get("/workspace/test_path") or {panic(err)}
// 	mut file := test_path_dir.file_find("newfile1") or {panic(err)}
// 	assert file.exists == 1
// 	println("file $file found")

// 	// assert test_path_dir.file_find("newfile2")
// 	// println("file newfile1 not found")
// }

fn test_list(){
	println('************ TEST_list ************')
	mut test_path_dir := path.get("/workspace/test_path") or {panic(err)}
	result := test_path_dir.list("", true) or {panic(err)}
	println(result)
}

fn test_list_dirs(){
	println('************ TEST_list_dir ************')
	mut test_path_dir := path.get("/workspace/test_path") or {panic(err)}
	result := test_path_dir.dir_list("", true) or {panic(err)}
	println(result)
}

fn test_list_files(){
	println('************ TEST_list_files ************')
	mut test_path_dir := path.get("/workspace/test_path") or {panic(err)}
	result := test_path_dir.file_list("", true) or {panic(err)}
	println(result)
}

fn test_list_links(){
	println('************ TEST_list_link ************')
	mut test_path_dir := path.get("/workspace/test_path") or {panic(err)}
	result := test_path_dir.link_list("") or {panic(err)}
	println(result)
}

// fn test_write(){
// 	println('************ TEST_ ************')

// }

// fn test_read(){
// 	println('************ TEST_ ************')
	
// }

// fn test_copy(){
// 	println('************ TEST_ ************')
	
// }

// fn test_link(){
// 	println('************ TEST_link ************')
// 	mut dest_p:= path.Path{path:"/workspace/test_path/linkdir1", cat:path.Category.linkdir, exists:2}
// 	mut lp := path.Path{path:"/workspace/crystallib/path", cat:path.Category.dir, exists:1}
// 	lp.link(dest_p) or {panic(err)}
// 	mut get_link := path.get("/workspace/test_path/linkdir1") or {panic(err)}
// 	assert get_link.exists()
// 	println("Link path: $get_link.path")
// 	real:= get_link.path_absolute()
// 	println("Real path: $real")
// }