module tests

import freeflowuniverse.crystallib.develop.gittools
import os
import time

__global (
    branch_name_tests string
    tag_name_tests string
)

// Setup function that will run before each test
fn setup_generators(){
    runtime := time.now().unix()
    branch_name_tests = "branch${runtime}"
    tag_name_tests = "tag_${runtime}"
}

// Test to create a new branch in the repository and verify that the branch was not checked out by default.
//
// Steps:
// - Setup repository directory.
// - Clone the repository.
// - Create a new branch.
// - Verify that the branch is not checked out.
[test]
fn test_branch_create() {
    setup_generators()
    repo_setup := setup_repo()!

    mut gs := gittools.new(coderoot: repo_setup.coderoot)!
    mut repo := gs.get_repo(url: repo_setup.repo_url)!
    
    repo_path := repo.get_path()!
    assert os.exists(repo_path) == true
    
    repo.branch_create(branch_name_tests)!
    assert repo.status_local.branch != branch_name_tests
}

// Test to create and then check out a branch in the repository.
//
// Steps:
// - Setup repository directory.
// - Get the cloned repository.
// - Switch to a created branch.
// - Verify the branch was switched.
[test]
fn test_switch() {
    repo_setup := setup_repo()!
    mut gs := gittools.new(coderoot: repo_setup.coderoot)!
    mut repo := gs.get_repo(url: repo_setup.repo_url)!
    repo.branch_switch(branch_name_tests)!
    assert repo.status_local.branch == branch_name_tests 
}

// Test checkout to the base branch.
//
// Steps:
// - Setup repository directory.
// - Get the cloned repository.
// - Create a new tag.
// - Verify the tag was created.
[test]
fn test_tag_create() {
    repo_setup := setup_repo()!
    mut gs := gittools.new(coderoot: repo_setup.coderoot)!
    mut repo := gs.get_repo(url: repo_setup.repo_url)!

    repo.tag_create(tag_name_tests)!
    assert repo.tag_exists(tag_name_tests)! == true

    // Delete the full dir
    repo_setup.clean()!
}
