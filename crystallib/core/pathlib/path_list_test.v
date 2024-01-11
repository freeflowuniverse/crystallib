import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
import os

const testpath = os.dir(@FILE) + '/testdata'

fn testsuite_begin() {
	os.rmdir_all(testpath) or {}
	assert !os.is_dir(testpath)
	os.mkdir_all(testpath) or { panic(err) }
	os.mkdir_all('${testpath}/test_parent') or { panic(err) }

	// create some files for testing
	os.create('${testpath}/testfile.txt')!
	os.create('${testpath}/test_parent/subfile.txt')!
	os.mkdir('${testpath}/test_parent/test_child')!
	os.create('${testpath}/test_parent/test_child/subsubfile.txt')!
}

fn testsuite_end() {
	os.rmdir_all(testpath) or {}
}

fn test_list() {
	console.print_stdout('************ TEST_list ************')
	mut test_path_dir := pathlib.get('${testpath}')
	result := test_path_dir.list(recursive: true) or { panic(err) }
	println(result)
}

fn test_list_dirs() {
	console.print_stdout('************ TEST_list_dir ************')
	mut test_path_dir := pathlib.get('${testpath}')
	result := test_path_dir.list(recursive: true) or { panic(err) }
	println(result)
}

fn test_list_files() {
	console.print_stdout('************ TEST_list_files ************')
	mut test_path_dir := pathlib.get('${testpath}')
	mut fl := test_path_dir.list() or { panic(err) }
	result := fl.paths
	assert result.len == 5
}

fn test_list_links() {
	console.print_stdout('************ TEST_list_link ************')
	mut test_path_dir := pathlib.get('${testpath}')
	result := test_path_dir.list(pathlib.ListArgs{}) or { panic(err) }
	println(result)
}
