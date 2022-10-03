import freeflowuniverse.crystallib.pathlib
import os

const testpath = os.dir(@FILE) + '/examples/test_path'

fn test_get() {
	println('************ TEST_Get ************')
	println(testpath)
	fp := pathlib.get('$testpath/newfile1')
	assert fp.cat == pathlib.Category.file
	println('File Result: $fp')
	dp := pathlib.get('$testpath')
	assert dp.cat == pathlib.Category.dir
	println('Dir Result: $dp')
}

fn test_exists() {
	println('************ TEST_exists ************')
	mut p1 := pathlib.get_file('$testpath/newfile1', false) or { panic('$err') }
	assert p1.exists()
	println('File found')
	mut p2 := pathlib.get_file('$testpath/NotARealFile', false) or { panic('$err') }
	assert !p2.exists()
	println('File not found')
	mut p3 := pathlib.get_file('$testpath/NotARealFile2', true) or { panic('$err') }
	assert p3.exists()
	println('File found')
	p3.delete() or { panic('$err') }
	assert !p3.exists()
}

fn test_parent() {
	println('************ TEST_test_parent ************')
	mut test_path_dir := pathlib.get('$testpath')
	mut p := pathlib.get('$testpath/newfile1')
	parent_dir := p.parent() or { panic(err) }
	assert parent_dir == test_path_dir
	println('Parent Function working correctly')
}

fn test_parent_find() {
	println('************ TEST_test_parent_find ************')
	// - newfile1 is located in test_path
	// - will start search from test_parent that is inside test_path
	// - Result must be test_path
	mut test_path_dir := pathlib.get('$testpath')
	mut p := pathlib.get('$testpath/test_parent')
	mut p2 := pathlib.get('$testpath/test_parent/newfile1')
	p2.delete() or { panic(err) }
	parent_dir := p.parent_find('newfile1') or { panic(err) }
	assert parent_dir.path == test_path_dir.path
	println('Find Parent Function working correctly')
}

fn test_dir_exists() {
	println('************ TEST_dir_exists ************')
	mut test_path_dir := pathlib.get('$testpath')
	assert test_path_dir.dir_exists('test_parent')
	println('test_parent found in $test_path_dir.path')
	assert !test_path_dir.dir_exists('test_parent_2')
	println('test_paren_2 not found in $test_path_dir.path')
}

fn test_dir_find() {
	println('************ TEST_dir_find ************')
	mut test_path_dir := pathlib.get('$testpath')
	mut test_parent_dir := test_path_dir.dir_get('test_parent') or { panic(err) }
	println('Dir found: $test_parent_dir')
	mut test_parent_dir2 :=test_path_dir.dir_get("test_parent_2") or { return }
	panic("should not get here")
}

fn test_file_exists() {
	println('************ TEST_file_exists ************')
	mut test_path_dir := pathlib.get('$testpath')
	assert test_path_dir.file_exists('newfile1')
	println('newfile1 found in $test_path_dir.path')

	assert !test_path_dir.file_exists('newfile2')
	println('newfile2 not found in $test_path_dir.path')
}

fn test_file_find() {
	println('************ TEST_file_find ************')
	mut test_path_dir := pathlib.get('$testpath')
	mut file := test_path_dir.file_find('newfile1') or { panic(err) }
	println('file $file found')
	test_path_dir.file_find("newfile2") or {return}
	panic("should not get here")
}

fn test_link_path_relative() {
	a1:=pathlib.path_relative("/a/b/c/d.txt","/a/d.txt")
	assert a1=="../../d.txt"
	a2:=pathlib.path_relative("/a/b/c/d.txt","/d.txt")
	assert a2=="../../../d.txt"
	a3:=pathlib.path_relative("/a/b/c/d.txt","/a/b/c/e.txt")
	assert a3=="e.txt"// TODO: is wrong this should give error I guess
	a4:=pathlib.path_relative("/a/b/c/d.txt","/a/b/d/e.txt")
	assert a4=="../d/e.txt"
	a5:=pathlib.path_relative("/a/b/c/d.txt","/a/b/c/d/e/e.txt")
	println(a5)
	// assert a5=="d/e/e.txt"
	a6:=pathlib.path_relative("/a/b/c/","/a/b/c/e.txt")
	assert a6=="e.txt"
	a7:=pathlib.path_relative("/a/b/c","/a/b/c/e.txt")
	assert a7=="e.txt"
	a8:=pathlib.path_relative("/a/b/c","/a/b/c/d/e/e.txt")
	assert a8=="d/e/e.txt"	
	panic("sss")
}

fn test_symlink() {
	println('************ SYMLINK ************')
	mut p := pathlib.get('$testpath/test_parent/readme.md')
	assert p.exists()
	mut p2:=p.link("$testpath/link_remove",true) or {panic("no link")}
	println(p2)
	panic("sww")
}



fn test_list() {
	println('************ TEST_list ************')
	mut test_path_dir := pathlib.get('$testpath')
	result := test_path_dir.list(recursive: true) or { panic(err) }
	println(result)
}

fn test_list_dirs() {
	println('************ TEST_list_dir ************')
	mut test_path_dir := pathlib.get('$testpath')
	result := test_path_dir.dir_list(recursive: true) or { panic(err) }
	println(result)
}

fn test_list_files() {
	println('************ TEST_list_files ************')
	mut test_path_dir := pathlib.get('$testpath')
	result := test_path_dir.file_list(recursive: true) or { panic(err) }
	println(result)
}

fn test_list_links() {
	println('************ TEST_list_link ************')
	mut test_path_dir := pathlib.get('$testpath')
	result := test_path_dir.link_list(pathlib.ListArgs{}) or { panic(err) }
	println(result)
}

fn test_write_and_read() {
	println('************ TEST_write_and_read ************')
	mut fp := pathlib.get('$testpath/newfile1')
	fp.write('Test Write Function') or { panic(err) }
	fcontent := fp.read() or { panic(err) }
	assert fcontent == 'Test Write Function'
	println('Write and read working correctly')

	// mut test_path_dir := pathlib.get("$testpath")
}

fn test_copy() {
	println('************ TEST_copy ************')
	//- Copy /test_path/newfile1 to /test_path/test_parent
	mut dest_dir := pathlib.get('$testpath/test_parent')
	mut src_f := pathlib.get('$testpath/newfile1')
	dest_file := src_f.copy(mut dest_dir) or { panic(err) }
	assert dest_file.path == '$testpath/test_parent/newfile1'
	println('Copy function works correctly')
}

// TODO need other test
// fn test_link(){
// 	println('************ TEST_link ************')
// 	mut dest_p:= path.path{path:"$testpath/linkdir1", cat:pathlib.Category.linkdir, exists:path.false}
// 	mut lp := path.path{path:"/workspace/crystallib/path", cat:pathlib.Category.dir, exists:path.true}
// 	lp.link(mut dest_p) or {panic(err)}
// 	mut get_link := pathlib.get("$testpath/linkdir1")
// 	assert get_link.exists()
// 	println("Link path: $get_link.path")
// 	real:= get_link.absolute()
// 	println("Real path: $real")
// }

fn test_find_common_ancestor() {
	println('************ TEST_find_common_ancestor ************')
	res:=pathlib.find_common_ancestor(["/test/a/b/c/d","/test/a/"])
	assert res=="/test/a"

	b1:=pathlib.find_common_ancestor(["/a/b/c/d.txt","/a/d.txt"])
	assert b1=="/a"

	b2:=pathlib.find_common_ancestor(["/a/b/c/d.txt","/c/d.txt"])
	assert b2=="/"

	b3:=pathlib.find_common_ancestor(["/a/b/c/d.txt","/a/b/c/e.txt"])
	assert b3=="/a/b/c"

	b4:=pathlib.find_common_ancestor(["/a/b/c/d.txt","/a/b/c/d.txt"])
	assert b4=="/a/b/c/d.txt"

	b5:=pathlib.find_common_ancestor(["","/a/b/c/d.txt"])
	assert b5=="/"

	b6:=pathlib.find_common_ancestor(["/a/b/c/d.txt",""])
	assert b6=="/"

	b7:=pathlib.find_common_ancestor(["/","/a/b/c/d.txt"])
	assert b7=="/"	

}