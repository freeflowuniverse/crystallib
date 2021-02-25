module gittools

import os
import process

pub fn (mut repo GitRepo) path_get() string {
	if repo.path == '' {
		return repo.addr.path_get()
	} else {
		return repo.path
	}
}

fn (mut repo GitRepo) url_get() string {
	return repo.addr.url_get()
}

// if there are changes then will return 'true', otherwise 'false'
pub fn (mut repo GitRepo) changes() ?bool {
	cmd := 'cd $repo.addr.path_get() && git status'
	out := process.execute_silent(cmd) or {
		return error('Could not execute command to check git status on $repo.path\ncannot execute $cmd')
	}
	// println(out)
	if out.contains('Untracked files') {
		return true
	} else if out.contains('Your branch is ahead of') {
		return true
	} else if out.contains('Changes not staged for commit') {
		return true
	} else if out.contains('nothing to commit') {
		return false
	} else {
		return true
	}
	// println(out)
	return true
}

pub struct PullArgs {
	force      bool
	force_ssh  bool
	force_http bool
}

pub fn (mut repo GitRepo) repo_url_get() ?string {
	key_path := '$os.home_dir()/.ssh/$repo.addr.name'

	// println(" - check keypath: $key_path")

	// println(ssh_agent_key_loaded("info_digitaltwin"))
	// panic("ss")

	nrkeys, exists := ssh_agent_key_loaded(repo.addr.name)
	println(' >>> $repo.addr.name $nrkeys, $exists')

	if os.exists(key_path) {
		println(' -- FOUND')
		if (!exists) || nrkeys > 1 {
			ssh_agent_reset() ?
			ssh_agent_load(key_path) ?
			return repo.addr.url_ssh_get()
		} else if exists && nrkeys == 1 {
			return repo.addr.url_ssh_get()
		} else {
			return repo.addr.url_http_get()
		}
	}
	if nrkeys == 1 {
		return repo.addr.url_ssh_get()
	} else {
		return repo.addr.url_http_get()
	}
}

// pulls remote content in, will fail if there are local changes
// when using force:true it means we reset, overwrite all changes
pub fn (mut repo GitRepo) pull(args PullArgs) ? {
	mut cmd := ''

	url := repo.repo_url_get() ?

	println(' - PULL: $url')

	if os.exists(repo.path_get()) {
		// LETS NOT DO YET, we first need to make sure that a repo can be loaded with ssh, there needs to be a check
		// if ssh_agent_loaded() {
		// 	repo.change_to_ssh() or {
		// 		if err != '' {
		// 			return error('cannot change to ssh for $repo.path')
		// 		}
		// 	}
		// }

		if args.force {
			if repo.addr.branch == '' {
				cmd = 'cd $repo.path_get() && git clean -xfd && git checkout .'
			} else {
				cmd = 'cd $repo.path_get() && git clean -xfd && git checkout . && git checkout $repo'
			}
			process.execute_silent(cmd) or {
				return error('Cannot pull repo: ${repo.path}. Error was $err')
			}
		}
		cmd = 'cd $repo.addr.path_get() && git pull'

		process.execute_silent(cmd) or {
			println(' GIT FAILED: $cmd')
			return error('Cannot pull repo: ${repo.path}. Error was $err')
		}
	} else {
		cmd = 'mkdir -p $repo.addr.path_account_get() && cd $repo.addr.path_account_get() && git clone $url'
		if repo.addr.branch != '' {
			cmd += ' -b $repo.addr.branch'
		}
		if repo.addr.depth != 0 {
			cmd += ' --depth=$repo.addr.depth  && cd $repo.addr.name && git fetch'
		}

		process.execute_silent(cmd) or {
			println(' GIT FAILED: $cmd')
			return error('Cannot pull repo: ${repo.path}. Error was $err')
		}
	}
}

pub fn (mut repo GitRepo) commit(msg string) ? {
	change := repo.changes() or {
		return error('cannot detect if there are changes on repo.\n$err')
	}
	if change {
		cmd := '
		cd $repo.addr.path_get()
		set +e
		git add . -A
		git commit -m \"$msg\"
		echo ""
		'
		process.execute_silent(cmd) or {
			return error('Cannot commit repo: ${repo.path}. Error was $err')
		}
	} else {
		println('     > no change')
	}
}

pub fn (mut repo GitRepo) remove_changes() ? {
	change := repo.changes() or {
		return error('cannot detect if there are changes on repo.\n$err')
	}
	if change {
		println(' - remove change $repo.path')
		cmd := '
		cd $repo.addr.path_get()
		set +e
		#checkout . -f
		git reset HEAD --hard
		git clean -fd
		echo ""
		'
		process.execute_silent(cmd) or {
			return error('Cannot commit repo: ${repo.path}. Error was $err')
		}
	} else {
		println('     > no change  $repo.path')
	}
}

pub fn (mut repo GitRepo) push() ? {
	repo.repo_url_get() ?

	cmd := 'cd $repo.addr.path_get() && git push'
	process.execute_silent(cmd) or {
		return error('Cannot push repo: ${repo.path}. Error was $err')
	}
}

// make sure we use ssh instead of https in the config file
fn (mut repo GitRepo) change_to_ssh() ? {
	path2 := repo.path_get()
	if !os.exists(path2) {
		// nothing to do
		return
	}

	pathconfig := os.join_path(path2, '.git', 'config')
	if !os.exists(pathconfig) {
		return error("path: '$path2' is not a git dir, missed a .git/config file. Could not change git to ssh repo.")
	}
	content := os.read_file(pathconfig) or {
		return error('Failed to load config $pathconfig for sshconfig')
	}

	mut result := []string{}
	mut line2 := ''
	mut found := false
	for line in content.split_into_lines() {
		// see if we can find the line which has the url
		pos := line.index('url =') or { 0 }
		if pos > 0 {
			line2 = line[0..pos] + 'url = ' + repo.url_get()
			found = true
		} else {
			line2 = line
		}
		result << line2
	}

	if found {
		os.write_file(pathconfig, result.join_lines()) or {
			return error('Failed to write config $pathconfig in change to ssh')
		}
	}
}
