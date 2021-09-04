module installers

import os
import despiegk.crystallib.publisher_config
import despiegk.crystallib.process
import despiegk.crystallib.texttools

pub fn wiki_cleanup(names []string) ? {

	mut conf := publisher_config.get()

	for mut site in conf.sites_get(names) {
		mut repo := site.repo_get()

		name := site.name

		println(' - cleanup wiki $repo.path()')

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
		os.write_file('$repo.path()/.gitignore', texttools.dedent(gitignore)) or {
			return error('cannot write to $repo.path()/.gitignore\n$err')
		}

		script_cleanup := '
		
		cd $repo.path()

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
		cd $repo.path()
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
		// cd $repo.path()
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
}
