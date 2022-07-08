module installers

import os
import freeflowuniverse.crystallib.publisher_config
import freeflowuniverse.crystallib.process
import freeflowuniverse.crystallib.texttools

pub fn website_cleanup(name string) ? {
	mut conf := publisher_config.get()?
	mut site := conf.site_get(name)?
	mut repo := site.repo_get()
	println(' - cleanup website $repo.path()')

	gitignore := '
	*.log
	!.env.example
	.cache
	.DS_Store
	src/.temp
	content/blog
	content/news
	content/person
	content/project
	node_modules
	!.env.example
	.env
	.env.*
	yarn.lock
	dist
	.installed
	install.sh
	run.sh
	build.sh
	package-lock.json
	src/errors.md
	session_data/*
	book
	book/
	boo/*
	"https*
	https*
	http*	
	.vscode
	'
	os.write_file('$repo.path()/.gitignore', texttools.dedent(gitignore)) or {
		return error('cannot write to $repo.path()/.gitignore\n$err')
	}

	readme := '
	# ThreeFold Website $name

	### how to get started

	see [getting started doc](https://github.com/threefoldfoundation/www_examplesite/blob/development/manual/install.md)

	### contribute

	see [best practices](https://github.com/threefoldfoundation/www_examplesite/blob/development/manual/contribute.md)

	> please make sure you work in line with instructions above

	'
	if !os.exists('$repo.path()/readme.md') {
		os.write_file('$repo.path()/readme.md', texttools.dedent(readme)) or {
			return error('cannot write to $repo.path()/README.md\n$err')
		}
	}
	script_cleanup := '
	
	cd $repo.path()

	rm -f yarn.lock
	rm -rf .cache		
	rm -rf modules
	rm -f .installed
	rm -rf dist
	rm -f package-lock.json

	#loose all changes
	git fetch origin
	#git reset HEAD --hard
	git reset --hard @{u}
	#git reset --hard origin/development
	git clean -fd	

	#remove again
	rm -f yarn.lock
	rm -rf .cache		
	rm -rf modules
	rm -f .installed
	rm -rf dist
	rm -f package-lock.json	

	git add . -A
	set +e
	git commit -m "cleanup" 
	set -e

	git pull
	rm -f install.sh
	rm -f run.sh
	rm -f build.sh
	rm -f install_gridsome.sh
	
	if ! [ "$name" = "www_examplesite" ]; then
		rm -f content/blog
		rm -f content/news
		rm -f content/person
		rm -f content/project	
	fi	
	set +e
	git add . -A
	git commit -m "installer cleanup"
	set -e
	git pull
	git push

	#git checkout master
	#git merge development
	#set +e
	#git add . -A
	#git commit -m "installer cleanup"
	#set -e
	#git push
	#git checkout development

	'

	process.execute_stdout(script_cleanup) or { return error('cannot cleanup for ${name}.\n$err') }

	// TODO: we need to add code here to update a website from our example website, so we have newest code
}
