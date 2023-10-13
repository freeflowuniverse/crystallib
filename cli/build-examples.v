module main

import os
import vlang.testing
import v.pref

// ln -s ../../code/utils/v/cmd/tools/modules/testing .

const vroot = os.dir(os.real_path(os.getenv_opt('VEXE') or { @VEXE }))

// build as a project folder
const efolders = [
	'examples/viewer',
	'examples/vweb_orm_jwt',
	'examples/vweb_fullstack',
]

pub fn normalised_vroot_path(path string) string {
	return os.real_path(os.join_path_single(vroot, path)).replace('\\', '/')
}

fn main() {
	args_string := os.args[1..].join(' ')
	params := args_string.all_before('build-examples')
	mut skip_prefixes := efolders.map(normalised_vroot_path(it))
	res := v_build_failing_skipped(params, 'examples', skip_prefixes, fn (mut session testing.TestSession) {
		for x in efolders {
			pathsegments := x.split_any('/')
			session.add(os.real_path(os.join_path(vroot, ...pathsegments)))
		}
	})
	if res {
		exit(1)
	}
	if v_build_failing_skipped(params + '-live', os.join_path_single('examples', ''),
		skip_prefixes, fn (mut session testing.TestSession) {})
	{
		exit(1)
	}
}

pub type FnTestSetupCb = fn (mut session testing.TestSession)

pub fn v_build_failing_skipped(zargs string, folder string, oskipped []string, cb FnTestSetupCb) bool {
	main_label := 'Building ${folder} ...'
	finish_label := 'building ${folder}'
	mut session := prepare_test_session(zargs, folder, oskipped, main_label)
	cb(mut session)
	session.test()
	eprintln(session.benchmark.total_message(finish_label))
	return session.failed_cmds.len > 0
}

pub fn prepare_test_session(zargs string, folder string, oskipped []string, main_label string) testing.TestSession {
	vexe := pref.vexe_path()
	file_dir := os.dir(os.dir(@FILE))
	parent_dir := '${file_dir}'
	// testing.vlib_should_be_present(parent_dir)
	vargs := zargs.replace(vexe, '')
	testing.eheader(main_label)
	if vargs.len > 0 {
		eprintln('v compiler args: "${vargs}"')
	}
	mut session := testing.new_test_session(vargs, true)
	files := os.walk_ext(os.join_path_single(parent_dir, folder), '.v')
	mut mains := []string{}
	mut skipped := oskipped.clone()
	next_file: for f in files {
		fnormalised := f.replace('\\', '/')
		// Note: a `testdata` folder, is the preferred name of a folder, containing V code,
		// that you *do not want* the test framework to find incidentally for various reasons,
		// for example module import tests, or subtests, that are compiled/run by other parent tests
		// in specific configurations, etc.
		if fnormalised.contains('testdata/') || fnormalised.contains('modules/')
			|| fnormalised.contains('preludes/') {
			continue
		}
		$if windows {
			// skip process/command examples on windows
			if fnormalised.ends_with('examples/process/command.v') {
				continue
			}
		}
		c := os.read_file(f) or { panic(err) }
		maxc := if c.len > 500 { 500 } else { c.len }
		start := c[0..maxc]
		if start.contains('module ') && !start.contains('module main') {
			skipped_f := f.replace(os.join_path_single(parent_dir, ''), '')
			skipped << skipped_f
		}
		for skip_prefix in oskipped {
			skip_folder := skip_prefix + '/'
			if fnormalised.starts_with(skip_folder) {
				continue next_file
			}
		}
		mains << f
	}
	session.files << mains
	session.skip_files << skipped
	return session
}
