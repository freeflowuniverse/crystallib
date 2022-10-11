import freeflowuniverse.crystallib.pathlib { Path }
import os

const testpath = os.dir(@FILE) + '/examples/test_path'

fn testsuite_begin() {
	os.rmdir_all(testpath) or {}
	assert !os.is_dir(testpath)
	os.mkdir_all(testpath) or {panic(err)}
	os.mkdir_all('$testpath/test_parent') or {panic(err)}
	os.create('$testpath/test_parent/testfile2.md') or {panic(err)}
	os.create('$testpath/test_parent/testfile3.md') or {panic(err)}
}

fn testsuite_end() {
	os.rmdir_all(testpath) or {}
}

fn test_link() {
	println('************ TEST_link ************')
	mut source1 := pathlib.get('$testpath/test_parent/testfile2.md')
	mut source2 := pathlib.get('$testpath/test_parent/testfile3.md')
	assert source1.exists()
	assert source2.exists()

	// below fails because dest path is a nonexisting file without .ext
	// so path_relative can't determine if file or dir and
	// mut dest := pathlib.get('$testpath/test_link')
	// assert !dest.exists()
	// mut link1 := source1.link(dest.path, true) or { panic('no link: $err') }
	// assert link1.path == '$testpath/test_link'
	// dest = pathlib.get('$testpath/test_link')
	// assert dest.exists()

	// test delete exists with nonexistent dest
	mut dest := pathlib.get('$testpath/test_link.md')
	assert !dest.exists()
	mut link1 := source1.link(dest.path, true) or { panic('no link: $err') }
	assert link1.path == '$testpath/test_link.md'
	dest = pathlib.get('$testpath/test_link.md')
	assert dest.exists()

	// test delete exists with existing dest
	assert dest.realpath() == source1.path
	mut link2 := source2.link(dest.path, true) or { panic('no link $err') }
	assert link2.path == '$testpath/test_link.md'
	assert link2.realpath() != source1.path
	assert link2.realpath() == source2.path

	// test delete_exists false with existing dest
	dest = pathlib.get('$testpath/test_link.md')
	assert dest.realpath() == source2.path
	mut link3 := source1.link(dest.path, false) or { Path{} }
	assert link3.path == '' // link should error so check empty path obj
	dest = pathlib.get('$testpath/test_link.md')
	assert dest.realpath() == source2.path // dest reamins unchanged

	dest.delete()?
	println('Link function working correctly')
}

fn test_readlink() {
	println('************ TEST_readlink ************')
	// test with none link path
	mut source := pathlib.get('$testpath/test_parent/testfile2.md')
	mut dest_ := '$testpath/test_readlink.md'
	path := source.readlink() or { Path{} }
	assert path == Path{}

	// test with filelink path
	mut link := source.link(dest_, true) or { panic('error: $err') }
	mut dest := pathlib.get(dest_)

	assert dest.cat == .linkfile
	assert dest.path == dest_

	link_source := dest.readlink() or { Path{} }
	assert link_source.path == 'test_parent/testfile2.md'

	dest.delete()?
	println('Readlink function working correctly')
}

fn test_unlink() {
	println('************ TEST_unlink ************')
	// test with filelink path

	mut source := pathlib.get('$testpath/test_parent/testfile2.md')
	mut dest_ := '$testpath/test_unlink.md'

	mut link := source.link(dest_, true) or { panic('error: $err') }
	mut dest := pathlib.get(dest_)

	// TODO: check if content is from source

	assert dest.cat == .linkfile
	dest.unlink() or { panic('Failed to unlink: $err') }
	assert dest.exists()
	assert dest.cat == .file

	dest.delete()?

	// TODO: maybe more edge cases?
	println('Unlink function working correctly')
}

fn test_relink() {
	println('************ TEST_relink ************')

	mut source := pathlib.get('$testpath/test_parent/testfile2.md')
	mut dest_ := '$testpath/test_relink.md'
	mut link := source.link(dest_, true) or { panic('error: $err') }
	mut dest := pathlib.get(dest_)

	// linked correctly so doesn't change
	assert source.cat == .file
	assert dest.cat == .linkfile
	dest.relink() or { panic('Failed to relink: $err') }
	source_new := pathlib.get(source.path)
	assert source_new.cat == .file
	assert dest.cat == .linkfile

	// switching source and destination
	mut source2 := pathlib.get(dest_)
	source2.unlink() or { panic('Failed to unlink: $err') }
	mut dest2_ := source.path

	// linked incorrectly so should relink
	mut link2 := source2.link(dest2_, true) or { panic('error: $err') }
	mut dest2 := pathlib.get(dest2_)
	assert source2.cat == .file
	assert dest2.cat == .linkfile
	dest2.relink() or { panic('Failed to relink: $err') }
	source2_new := pathlib.get(source2.path)
	assert source2_new.cat == .linkfile
	assert dest2.cat == .file

	dest.delete()?
}
