module tests

import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.osal
import os
import time

// Test to clone a repository and verify that it exists locally.
//
// Steps:
// - Setup repository directory.
// - Clone the repository from the specified URL.
// - Verify that the repository name is correct.
// - Check if the repository path exists locally.
[test]
fn test_clone_repo() {
	// time.sleep(5 * time.second)
    repo_setup := setup_repo()!

    mut gs := gittools.new(coderoot: repo_setup.coderoot)!
    mut repo := gs.get_repo(name: repo_setup.repo_name, clone: true, url: repo_setup.repo_url)!
    
    assert repo.name == "repo3"
    repo_path := repo.get_path()!
    assert os.exists(repo_path) == true
    
    repo_setup.clean()!
}
