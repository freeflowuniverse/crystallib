module gittools

import os

const (
	github_dir     = '${os.home_dir()}/testcode/github'
	crystallib_url = 'https://github.com/freeflowuniverse/crystallib.git'
)

fn testsuite_begin() {
	os.mkdir_all('${gittools.github_dir}/freeflowuniverse')!
	os.chdir('${gittools.github_dir}/freeflowuniverse')!
	os.execute('git clone ${gittools.crystallib_url}')
}

fn testsuite_end() {
	os.rmdir_all('${gittools.github_dir}/freeflowuniverse')!
	os.chdir('${gittools.github_dir}/freeflowuniverse')!
	os.execute('git clone ${gittools.crystallib_url}')
}

fn test_path_relative() {
}

fn test_changes() {
}

fn test_pull_reset() {
}

fn test_pull() {
}

fn test_commit() {
}

fn test_remove_changes() {
}

fn test_push() {
}

fn test_branch_get() {
}

fn test_branch_switch() {
}

fn test_fetch_all() {
}

fn test_delete() {
}

fn test_ssh_key_load_if_exists() {
}
