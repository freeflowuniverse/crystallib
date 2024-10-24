module tests

import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.osal
import os
import time

// Test to verify the detection of changes in the repository after creating a new file.
//
// Steps:
// - Setup repository directory.
// - Clone the repository.
// - Create a new file and verify the repository has changes.
// - Verify unstaged and staged changes before and after adding the changes.
[test]
fn test_has_changes_add_changes_commit_changes() {
    repo_setup := setup_repo()!
    
    mut gs := gittools.new(coderoot: repo_setup.coderoot)!
    mut repo := gs.get_repo(url: repo_setup.repo_url)!
    
    repo_path := repo.get_path()!
    assert os.exists(repo_path) == true

    file := create_new_file(repo_path)!

    assert repo.has_changes()! == true

    mut unstaged_changes := repo.get_changes_unstaged()!
    assert unstaged_changes.len == 1

    mut staged_changes := repo.get_changes_staged()!
    assert staged_changes.len == 0

    repo.commit('New file added')!

    staged_changes = repo.get_changes_staged()!
    assert staged_changes.len == 0

    unstaged_changes = repo.get_changes_unstaged()!
    assert unstaged_changes.len == 0

    repo_setup.clean()!
}
