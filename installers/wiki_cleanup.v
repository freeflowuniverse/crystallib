module installers

import os
import despiegk.crystallib.publisher_config
import despiegk.crystallib.process
import despiegk.crystallib.gittools
import despiegk.crystallib.texttools

pub fn wiki_cleanup(name string, conf &publisher_config.ConfigRoot) ? {
	codepath := conf.publish.paths.code

	mut gt := gittools.new(codepath,false) or { return error('ERROR: cannot load gittools:$err') }
	reponame := conf.reponame(name) ?
	mut repo := gt.repo_get(name: reponame) or { return error('ERROR: cannot load gittools:$err') }
	println(' - cleanup wiki $repo.path_get()')

	gitignore := '
	src/errors.md
	session_data/*
	book
	book/
	boo/*
	"https*
	https*
	http*
	"*
	docshttp*
	.vscode
	'
	os.write_file('$repo.path_get()/.gitignore', texttools.dedent(gitignore)) or {
		return error('cannot write to $repo.path_get()/.gitignore\n$err')
	}

	script_cleanup := '
	
	cd $repo.path_get()

	rm -rf .vscode
	rm -rf .cache		
	rm -rf modules
	rm -f .installed	

	#git reset HEAD --hard
	#git clean -fd	

	#loose all changes
	git fetch origin
	#git reset HEAD --hard
	git reset --hard @{u}
	#git reset --hard origin/development
	git clean -fd	

	#remove again	

	rm -rf .vscode
	rm -rf .cache		
	rm -rf modules
	rm -f .installed
	'

	process.execute_stdout(script_cleanup) or { return error('cannot cleanup for ${name}.\n$err') }

	script_commit := '
	cd $repo.path_get()
	set +e
	git add . -A
	git commit -m "wiki reformat"
	set -e
	git pull
	git push
	'

	process.execute_stdout(script_commit) or {
		return error('cannot script_commit for ${name}.\n$err')
	}

	// script_merge_master := '
	// set -ex
	// cd $repo.path_get()
	// set -e
	// git checkout master
	// git merge development
	// set +e
	// git add . -A
	// git commit -m "installer cleanup"
	// set -e
	// git push
	// git checkout development
	// '

	// process.execute_stdout(script_merge_master) or {
	// 	return error('cannot merge_master for ${name}.\n$err')
	// }
}
