import freeflowuniverse.crystallib.pathlib { Path }
import os

const testpath = os.dir(@FILE) + '/examples/test_path'

fn testsuite_begin() {
	os.rmdir_all(testpath) or {}
	assert !os.is_dir(testpath)
	os.mkdir_all(testpath) or {panic(err)}
	os.mkdir_all('$testpath/test_parent') or {panic(err)}
}

fn testsuite_end() {
	os.rmdir_all(testpath) or {}
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