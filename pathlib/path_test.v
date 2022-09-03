import freeflowuniverse.crystallib.path
import os

const testpath = os.dir(@FILE) + '/test_path'

fn test_get() {
	println('************ TEST_Get ************')
	println(testpath)
	fp := pathlib.get('$testpath/newfile1')
	assert fp.cat == path.Category.file
	println('File Result: $fp')
	dp := pathlib.get('$testpath')
	assert dp.cat == path.Category.dir
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
	parent_dir := p.parent()
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
	mut test_parent_dir := test_path_dir.dir_find('test_parent') or { panic(err) }
	println('Dir found: $test_parent_dir')

	// assert test_path_dir.dir_find("test_parent_2")
	// println("Dir test_parent_2 not found")
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

	// assert test_path_dir.file_find("newfile2")
	// println("file newfile1 not found")
}

fn test_list() {
	println('************ TEST_list ************')
	mut test_path_dir := pathlib.get('$testpath')
	result := test_path_dir.list('', true) or { panic(err) }
	println(result)
}

fn test_list_dirs() {
	println('************ TEST_list_dir ************')
	mut test_path_dir := pathlib.get('$testpath')
	result := test_path_dir.dir_list('', true) or { panic(err) }
	println(result)
}

fn test_list_files() {
	println('************ TEST_list_files ************')
	mut test_path_dir := pathlib.get('$testpath')
	result := test_path_dir.file_list('', true) or { panic(err) }
	println(result)
}

fn test_list_links() {
	println('************ TEST_list_link ************')
	mut test_path_dir := pathlib.get('$testpath')
	result := test_path_dir.link_list('') or { panic(err) }
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
	dest_file := src_f.copy(dest_dir) or { panic(err) }
	assert dest_file.path == '$testpath/test_parent/newfile1'
	println('Copy function works correctly')
}

// TODO need other test
// fn test_link(){
// 	println('************ TEST_link ************')
// 	mut dest_p:= path.Path{path:"$testpath/linkdir1", cat:path.Category.linkdir, exists:path.false}
// 	mut lp := path.Path{path:"/workspace/crystallib/path", cat:path.Category.dir, exists:path.true}
// 	lp.link(mut dest_p) or {panic(err)}
// 	mut get_link := pathlib.get("$testpath/linkdir1")
// 	assert get_link.exists()
// 	println("Link path: $get_link.path")
// 	real:= get_link.absolute()
// 	println("Real path: $real")
// }
