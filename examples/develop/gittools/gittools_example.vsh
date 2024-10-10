#!/usr/bin/env -S v -gc none -no-retry-compilation -cc tcc -d use_openssl -enable-globals run

import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.osal
import time

// Reset all configurations and caches
// gittools.cachereset()!

// Initialize the Git structure with the coderoot path
coderoot := '~/code'
mut gs_default := gittools.new(coderoot: coderoot)!

// Print all repositories in the specified coderoot
// gs_default.repos_print()!

// Example of getting the path of a specific repository
// mut path := gittools.code_get(
// 	coderoot:   coderoot
// 	url:        'https://github.com/Mahmoud-Emad/repo2'
// )!

// We get the repo
mut repo := gs_default.repo_get(name: 'repo2')!
repo_path := repo.path()!
coded_now := time.now().nanosecond
file_name := 'hello_world_${coded_now}.py'
// Then we need to create a new file in the repo
// osal.execute_silent(
// 	"echo \"Hello, World!\" > ${repo_path}/${file_name}"
// )!

// Now we need to check first is the repo has changes to add.
if repo.has_changes()!{
	// repo.add_changes()!
}

// Now we need to check first is the repo needs a commit.
if repo.need_commit()!{
	// repo.commit(msg: 'feat: Added ${file_name} file.')!
}

if repo.need_push()!{
	println('yeah')
	zeko := osal.execute_silent('cd ${repo_path} && git rev-parse HEAD')!
	println('zeko, ${zeko}')
}

// println(repo.status_local)




// // repo.open_vscode()!
// url := repo.need_commit()!
// println("need_commit: ${url}")
// // // List all repositories again
// // // gs_default.repos_print()!

// // // Print the exact path of the repository
// println("Repository path: ${path}")