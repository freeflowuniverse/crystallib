module tests

import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.osal
import os
import time

struct GittoolsTests {
    coderoot  string
    repo_dir  string
    repo_url  string
    repo_name string
}

// Creates a new Python file with 'Hello, World!' content in the specified repository path.
// The file name includes a timestamp to ensure uniqueness.
//
// Args:
// - repo_path (string): Path to the repository where the new file will be created.
// - runtime (i64): Unix timestamp used to generate a unique file name.
//
// Returns:
// - string: Name of the newly created file.
fn create_new_file(repo_path string, runtime i64)! string {
	coded_now := time.now().unix()
	file_name := 'hello_world_${coded_now}.py'
	osal.execute_silent("echo \"print('Hello, World!')\" > ${repo_path}/${file_name}")!
	return file_name
}

// Sets up a GittoolsTests instance with predefined values for repository setup.
//
// Returns:
// - GittoolsTests: Struct containing information about the repo setup.
fn setup_repo() !GittoolsTests {   
    ts := GittoolsTests{
        coderoot: '/tmp/code',
        repo_dir: '/tmp/code/github/Mahmoud-Emad',
        repo_url: 'https://github.com/Mahmoud-Emad/repo2.git',
        repo_name: 'repo3',
    }
    os.mkdir_all(ts.repo_dir)! 
    return ts
}

// Removes the directory structure created during repository setup.
//
// Raises:
// - Error: If the directory cannot be removed.
fn remove_setup()! {
    repo_setup := setup_repo()!
    os.rmdir_all(repo_setup.coderoot)!
}

// Test to clone a repository and verify that it exists locally.
//
// Steps:
// - Setup repository directory.
// - Clone the repository from the specified URL.
// - Verify that the repository name is correct.
// - Check if the repository path exists locally.
[test]
fn test_clone_repo() {
    repo_setup := setup_repo()!

    mut gs := gittools.new(coderoot: repo_setup.coderoot)!
    mut repo := gs.get_repo(name: repo_setup.repo_name, clone: true, url: repo_setup.repo_url)!
    
    assert repo.name == "repo3"
    repo_path := repo.get_path()!
    assert os.exists(repo_path) == true
    
    remove_setup()!
}

// Test to create a new branch in the repository and verify that the branch was not checked out by default.
//
// Steps:
// - Setup repository directory.
// - Clone the repository.
// - Create a new branch.
// - Verify that the branch is not checked out.
[test]
fn test_create_branch() {
    repo_setup := setup_repo()!
    
    mut gs := gittools.new(coderoot: repo_setup.coderoot)!
    mut repo := gs.get_repo(name: repo_setup.repo_name, clone: true, url: repo_setup.repo_url)!
    
    assert repo.name == "repo3"
    repo_path := repo.get_path()!
    assert os.exists(repo_path) == true

    runtime := time.now().unix()
    branch_name := "testing_${runtime}"
    
    repo.create_branch(branch_name: branch_name, checkout: false)!
    assert repo.status_local.branch != branch_name 
    
    remove_setup()!
}

// Test to create and then check out a branch in the repository.
//
// Steps:
// - Setup repository directory.
// - Clone the repository.
// - Create a new branch and checkout.
// - Verify the branch was checked out.
[test]
fn test_checkout_branch() {
    repo_setup := setup_repo()!
    
    mut gs := gittools.new(coderoot: repo_setup.coderoot)!
    mut repo := gs.get_repo(name: repo_setup.repo_name, clone: true, url: repo_setup.repo_url)!
    
    assert repo.name == "repo3"
    repo_path := repo.get_path()!
    assert os.exists(repo_path) == true

    runtime := time.now().unix()
    branch_name := "testing_${runtime}"
    
    repo.create_branch(branch_name: branch_name, checkout: false)!
    assert repo.status_local.branch != branch_name 
    
    repo.checkout_branch(branch_name: branch_name, pull: false)!
    assert repo.status_local.branch == branch_name 
    
    remove_setup()!
}

// Test to verify the detection of changes in the repository after creating a new file.
//
// Steps:
// - Setup repository directory.
// - Clone the repository.
// - Create a new branch and checkout.
// - Create a new file and verify the repository has changes.
[test]
fn test_has_changes() {
    repo_setup := setup_repo()!
    
    mut gs := gittools.new(coderoot: repo_setup.coderoot)!
    mut repo := gs.get_repo(name: repo_setup.repo_name, clone: true, url: repo_setup.repo_url)!
    
    assert repo.name == "repo3"
    repo_path := repo.get_path()!
    assert os.exists(repo_path) == true

    runtime := time.now().unix()
    branch_name := "testing_${runtime}"
    
    repo.create_branch(branch_name: branch_name, checkout: false)!
    assert repo.status_local.branch != branch_name 
    
    repo.checkout_branch(branch_name: branch_name, pull: false)!
    assert repo.status_local.branch == branch_name

    file := create_new_file(repo_path, runtime)!

    assert repo.has_changes()! == true
    
    remove_setup()!
}

// Test to add changes to the repository and verify that staged and unstaged changes are tracked correctly.
//
// Steps:
// - Setup repository directory.
// - Clone the repository.
// - Create a new branch and checkout.
// - Create a new file and add changes.
// - Verify unstaged and staged changes before and after adding the changes.
[test]
fn test_add_changes() {
    repo_setup := setup_repo()!
    
    mut gs := gittools.new(coderoot: repo_setup.coderoot)!
    mut repo := gs.get_repo(name: repo_setup.repo_name, clone: true, url: repo_setup.repo_url)!
    
    assert repo.name == "repo3"
    repo_path := repo.get_path()!
    assert os.exists(repo_path) == true

    runtime := time.now().unix()
    branch_name := "testing_${runtime}"
    
    repo.create_branch(branch_name: branch_name, checkout: false)!
    assert repo.status_local.branch != branch_name 
    
    repo.checkout_branch(branch_name: branch_name, pull: false)!
    assert repo.status_local.branch == branch_name

    file := create_new_file(repo_path, runtime)!

    assert repo.has_changes()! == true

    mut staged_changes := repo.get_staged_changes()!
    assert staged_changes.len == 0

    mut unstaged_changes := repo.get_unstaged_changes()!
    assert unstaged_changes.len != 0

    repo.add_changes()!

    staged_changes = repo.get_staged_changes()!
    assert staged_changes.len != 0

    unstaged_changes = repo.get_unstaged_changes()!
    assert unstaged_changes.len == 0

    remove_setup()!
}

// Test to commit changes to the repository and verify that staged and unstaged changes are tracked correctly.
//
// Steps:
// - Setup repository directory.
// - Clone the repository.
// - Create a new branch and checkout.
// - Create a new file and add changes.
// - Verify unstaged and staged changes before and after adding the changes.
// - Commit the changes.
// - Verify unstaged and staged changes before and after adding the changes.
[test]
fn test_commit_changes() {
    repo_setup := setup_repo()!
    
    mut gs := gittools.new(coderoot: repo_setup.coderoot)!
    mut repo := gs.get_repo(name: repo_setup.repo_name, clone: true, url: repo_setup.repo_url)!
    
    assert repo.name == "repo3"
    repo_path := repo.get_path()!
    assert os.exists(repo_path) == true

    runtime := time.now().unix()
    branch_name := "testing_${runtime}"
    
    repo.create_branch(branch_name: branch_name, checkout: false)!
    assert repo.status_local.branch != branch_name 
    
    repo.checkout_branch(branch_name: branch_name, pull: false)!
    assert repo.status_local.branch == branch_name

    file_name := create_new_file(repo_path, runtime)!

    assert repo.has_changes()! == true

    mut staged_changes := repo.get_staged_changes()!
    assert staged_changes.len == 0

    mut unstaged_changes := repo.get_unstaged_changes()!
    assert unstaged_changes.len != 0

    repo.add_changes()!

    staged_changes = repo.get_staged_changes()!
    assert staged_changes.len != 0

    unstaged_changes = repo.get_unstaged_changes()!
    assert unstaged_changes.len == 0

    assert repo.need_commit()! == true
    commit_msg := 'feat: Added ${file_name} file.'
	repo.commit(msg: commit_msg)!

    staged_changes = repo.get_staged_changes()!
    assert staged_changes.len == 0

    unstaged_changes = repo.get_unstaged_changes()!
    assert unstaged_changes.len == 0

    remove_setup()!
}

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
    
    repo.create_branch(branch_name: branch_name, checkout: false)!
    assert repo.status_local.branch != branch_name 
    
    repo.checkout_branch(branch_name: branch_name, pull: false)!
    assert repo.status_local.branch == branch_name

    file_name := create_new_file(repo_path, runtime)!

    assert repo.has_changes()! == true

    mut staged_changes := repo.get_staged_changes()!
    assert staged_changes.len == 0

    mut unstaged_changes := repo.get_unstaged_changes()!
    assert unstaged_changes.len != 0

    repo.add_changes()!

    staged_changes = repo.get_staged_changes()!
    assert staged_changes.len != 0

    unstaged_changes = repo.get_unstaged_changes()!
    assert unstaged_changes.len == 0

    assert repo.need_commit()! == true
    commit_msg := 'feat: Added ${file_name} file.'
	repo.commit(msg: commit_msg)!

    staged_changes = repo.get_staged_changes()!
    assert staged_changes.len == 0

    unstaged_changes = repo.get_unstaged_changes()!
    assert unstaged_changes.len == 0

    assert repo.need_push()! == true
    repo.push()!

    staged_changes = repo.get_staged_changes()!
    assert staged_changes.len == 0

    unstaged_changes = repo.get_unstaged_changes()!
    assert unstaged_changes.len == 0

    remove_setup()!
}
