

module gittools
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.develop.vscode
import freeflowuniverse.crystallib.develop.sourcetree
import os

@[params]
pub struct CloneArgs{
pub mut:
	forcehttp bool
	branch string

}

fn (repo GitRepo) get_clone_cmd(args CloneArgs) !string {
	mut url := repo.url_get()!
	if args.forcehttp{
		url = repo.url_http_get()!
	}
	mut cmd := ''

	mut light := ''
	if repo.gs.config.light {
		light = ' --depth 1 --no-single-branch'
	}

	mut path := repo.path_account()!
	// QUESTION: why was branch name used for repo?
	// cmd = 'cd ${path.path} && git clone ${light} ${url} ${repo.addr.branch}'
	cmd = 'cd ${path.path} && git clone ${light} ${url} ${repo.name}'	
	if args.branch != '' {
		cmd += ' -b ${args.branch}'
	}
	return cmd
}



// pulls remote content in, will reset changes
pub fn (mut repo GitRepo) pull_reset(args_ ActionArgs) ! {
	mut args := args_
	if args.reload {
		repo.load()!
		args.reload = false
	}
	repo.remove_changes(args)!
	repo.pull(args)!
}

@[params]
pub struct ActionArgs {
pub mut:
	reload bool = true
	msg    string // only relevant for commit
	branch string
	tag string
	recursive bool
}

// commit the changes, message is needed, pull from remote, push to remote
pub fn (mut repo GitRepo) commit_pull_push(args_ ActionArgs) ! {
	mut args := args_
	if args.reload {
		repo.load()!
		args.reload = false
	}
	repo.commit(args)!
	repo.pull(args)!
	repo.push(args)!
}

// commit the changes, message is needed, pull from remote
pub fn (mut repo GitRepo) commit_pull(args_ ActionArgs) ! {
	mut args := args_
	if args.reload {
		repo.load()!
		args.reload = false
	}
	repo.commit(args)!
	repo.pull(args)!
}

// pulls remote content in, will fail if there are local changes
pub fn (mut repo GitRepo) pull(args_ ActionArgs) ! {
	$if debug {
		console.print_debug('  pull: ${repo.url_get(true)} (branch: ${args_.branch})')
	}
	// repo.ssh_key_load()!
	// defer {
	// 	repo.ssh_key_forget() or { panic("bug") }
	// }

	mut args := args_
	if args.reload {
		repo.load()!
		args.reload = false
	}

	
	if args.branch != '' {
		//console.print_debug(" - branch detected: '${repo.addr.branch}'")
		if args.branch != repo.status_local.branch  {
			console.print_header(' branch pull ${repo.status_local.branch} -> ${args.branch} for ${repo.status_local.url}')
			repo.branch_switch(args.branch)!
		}
	}

	// } else {
	// 	print_backtrace()
	// 	return error('branch should have been known for ${repo.addr.remote_url}')

	// st := repo.status()!
	// if st.need_commit {
	// 	return error('Cannot pull repo: ${repo.path()!}, a commit is needed.\n${st}')
	// }
	// pull can't see the status
	cmd2 := 'cd ${repo.path()!} && git pull'
	osal.execute_silent(cmd2) or {
		console.print_debug(' GIT PULL FAILED: ${cmd2}')
		return error('Cannot pull repo: ${repo.path}. Error was ${err}')
	}

	if args.tag != '' {
		console.print_header("tag pull: '${args.tag}' for ${repo.status_local.url} ")
		cmd := 'cd ${repo.path()!} && git checkout ${args.tag}'
		osal.execute_silent(cmd) or {
			return error('Cannot pull tag ${args.tag} for  repo: ${repo.path()!}. \nError was ${err}')
		}
	}

	if args.recursive{
		cmd3:="cd ${repo.path()!} && git submodule update --init --recursive"
		osal.execute_silent(cmd3) or {
			console.print_debug(' GIT RECURSIVE PULL FAILED: ${cmd3}')
			return error('Cannot pull repo: ${repo.path}. Error was ${err}')
		}		
	}
	repo.load()!

	// repo.ssh_key_forget()!
}

// pub fn (mut repo GitRepo) rev() !string {
// 	// $if debug {
// 	// 	console.print_debug('   - REV: ${repo.url_get(true)}')
// 	// }
// 	cmd2 := 'cd ${repo.path()!} && git rev-parse HEAD'
// 	res := osal.execute_silent(cmd2) or {
// 		console.print_debug(' GIT REV FAILED: ${cmd2}')
// 		return error('Cannot rev repo: ${repo.path}. Error was ${err}')
// 	}
// 	return res.trim_space()
// }

pub fn (mut repo GitRepo) commit(args_ ActionArgs) ! {
	mut args := args_
	if args.reload {
		repo.load()!
		args.reload = false
	}
	if repo.need_commit() {
		if args.msg == '' {
			return error('Cannot commit, message is empty for ${repo}')
		}
		cmd := "
		cd ${repo.path()!}
		set +e
		git add . -A
		git commit -m \"${args.msg}\"
		echo "
		osal.execute_silent(cmd) or {
			return error('Cannot commit repo: ${repo.path()!}. Error was ${err}')
		}
	} else {
		console.print_debug('     > no change')
	}
	repo.load()!
}

// remove all changes of the repo, be careful
pub fn (mut repo GitRepo) remove_changes(args_ ActionArgs) ! {
	mut args := args_
	if args.reload {
		repo.load()!
		args.reload = false
	}
	if repo.need_commit() {
		console.print_header(' remove change ${repo.path()!}')
		cmd := '
		cd ${repo.path()!}
		rm -f .git/index
		#git fetch --all
		git reset HEAD --hard
		git clean -xfd		
		git checkout . -f
		echo ""
		'
		res := osal.exec(cmd: cmd, raise_error: false)!
		console.print_debug(cmd)
		// console.print_debug(res)
		if res.exit_code > 0 {
			console.print_header(' could not remove changes, will re-clone ${repo.path()!}')
			mut p:=repo.patho()!
			p.delete()! // remove path, this will re-clone the full thing
			panic("implement")
			//repo.load_from_url()!
		}
	}
	repo.load()!
}

pub fn (mut repo GitRepo) push(args_ ActionArgs) ! {
	mut args := args_
	if args.reload {
		repo.load()!
		args.reload = false
	}
	$if debug {
		console.print_debug('   - PUSH: ${repo.url_get(true)} on ${repo.path()!}')
	}
	// repo.ssh_key_load()!
	// defer {
	// 	repo.ssh_key_forget() or { panic(err) }
	// }
	if repo.need_push() {
		console.print_debug('    - PUSH THE CHANGES')
		cmd := 'cd ${repo.path()!} && git push'
		osal.execute_silent(cmd) or {
			return error('Cannot push repo: ${repo.path()!}. Error was ${err}')
		}
	}
	repo.load()!
	// repo.ssh_key_forget()!
}

pub fn (mut repo GitRepo) branch_switch(branchname string) ! {
	repo.load()!
	if repo.need_commit() || repo.need_push() {
		return error('Cannot branch switch repo: ${repo.path()!} because there are changes in the dir.')
	}
	// Fetch repo before checkout, in case a new branch added.
	repo.fetch_all()!
	cmd := 'cd ${repo.path()!} && git checkout ${branchname}'
	osal.execute_silent(cmd) or {
		// console.print_debug('GIT CHECKOUT FAILED: $cmd_checkout')
		return error('Cannot branch switch repo: ${repo.path()!}. Error was ${err} \n cmd: ${cmd}')
	}
	// console.print_debug(cmd)
	repo.pull(reload: true)!
}

pub fn (mut repo GitRepo) fetch_all() ! {
	// repo.ssh_key_load()!
	// defer {
	// 	repo.ssh_key_forget() or { panic(err) }
	// }
	cmd := 'cd ${repo.path()!} && git fetch --all'
	osal.execute_silent(cmd) or {
		// console.print_debug('GIT FETCH FAILED: $cmd_checkout')
		return error('Cannot fetch repo: ${repo.path()!}. Error was ${err} \n cmd: ${cmd}')
	}
	repo.load()!
	// repo.ssh_key_forget()!
}

// deletes git repository
pub fn (mut repo GitRepo) delete() ! {
	$if debug {
		console.print_debug('   - DELETE: ${repo.url_get(true)}')
	}
	if !os.exists(repo.path()!) {
		return
	} else {
		panic('implement')
	}
	repo.cache_delete()!
}


// open sourcetree for the git repo
pub fn (repo GitRepo) sourcetree() ! {
	sourcetree.open(path: repo.path()!)!
}

// open visual studio code for repo
pub fn (repo GitRepo) vscode() ! {
	vscode.open(path: repo.path()!)!
}
