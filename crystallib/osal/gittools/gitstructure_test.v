module gittools

import os

const (
	gitstructure_name = 'test_gitstructure'
	gitstructure_root = '${os.home_dir()}/testroot'
)

fn test_new() ! {
	assert !os.exists(gittools.gitstructure_root)

	new(
		name: gittools.gitstructure_name
		root: gittools.gitstructure_root
		multibranch: false
		light: false
		log: true
	)!

	if dir := os.getenv_opt('DIR_CODE') {
		assert os.exists(dir)
	} else {
		assert os.exists(gittools.gitstructure_root)
	}
}
