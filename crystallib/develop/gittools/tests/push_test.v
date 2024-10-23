module tests

import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.osal
import os
import time

// Test to push changes to the repository and verify that staged and unstaged changes are tracked correctly.
//
// Steps:
// - Setup repository directory.
// - Clone the repository.
// - Create a new branch and checkout.
// - Create a new file and add changes.
// - Verify unstaged and staged changes before and after adding the changes.
// - Commit the changes.
// - Verify unstaged and staged changes before and after adding the changes.
// - Push the changes.
// - Verify unstaged and staged changes before and after adding the changes.
[test]
fn test_push_changes() {
    repo_setup := setup_repo()!
    
    mut gs := gittools.new(coderoot: repo_setup.coderoot)!
    mut repo := gs.get_repo(name: repo_setup.repo_name, clone: true, url: repo_setup.repo_url)!
    
    assert repo.name == "repo3"
    repo_path := repo.get_path()!
    assert os.exists(repo_path) == true

    runtime := time.now().unix()
    branch_name := "testing_${runtime}"
    
    repo.branch_create(branch_name: branch_name, checkout: false)!
    assert repo.status_local.branch != branch_name 
    
    repo.checkout(branch_name: branch_name, pull: false)!
    assert repo.status_local.branch == branch_name

    file_name := create_new_file(repo_path, runtime)!

    assert repo.has_changes()! == true

    mut staged_changes := repo.get_changes_staged()!
    assert staged_changes.len == 0

    mut unstaged_changes := repo.get_changes_unstaged()!
    assert unstaged_changes.len != 0

    repo.add_changes()!

    staged_changes = repo.get_changes_staged()!
    assert staged_changes.len != 0

    unstaged_changes = repo.get_changes_unstaged()!
    assert unstaged_changes.len == 0

    assert repo.need_commit()! == true
    commit_msg := 'feat: Added ${file_name} file.'
	repo.commit(msg: commit_msg)!

    staged_changes = repo.get_changes_staged()!
    assert staged_changes.len == 0

    unstaged_changes = repo.get_changes_unstaged()!
    assert unstaged_changes.len == 0

    assert repo.need_push()! == true
    repo.push()!

    staged_changes = repo.get_changes_staged()!
    assert staged_changes.len == 0

    unstaged_changes = repo.get_changes_unstaged()!
    assert unstaged_changes.len == 0

    repo_setup.clean()!
}
