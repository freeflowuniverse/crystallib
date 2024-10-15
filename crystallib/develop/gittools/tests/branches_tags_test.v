module tests

import freeflowuniverse.crystallib.develop.gittools
import os
import time

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
    
    repo_setup.clean()!
}

// Test to create and then check out a branch in the repository.
//
// Steps:
// - Setup repository directory.
// - Clone the repository.
// - Create a new branch and checkout.
// - Verify the branch was checked out.
[test]
fn test_checkout() {
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
    
    repo.checkout(branch_name: branch_name, pull: false)!
    assert repo.status_local.branch == branch_name 
    
    repo_setup.clean()!
}

// Test checkout to the base branch.
//
// Steps:
// - Setup repository directory.
// - Clone the repository.
// - Create a new tag.
// - Verify the tag was created.
[test]
fn test_create_tag() {
    repo_setup := setup_repo()!
    
    mut gs := gittools.new(coderoot: repo_setup.coderoot)!
    mut repo := gs.get_repo(name: repo_setup.repo_name, clone: true, url: repo_setup.repo_url)!
    
    assert repo.name == "repo3"
    repo_path := repo.get_path()!
    assert os.exists(repo_path) == true

    runtime := time.now().unix()
    tag_name := "tag_${runtime}"

    repo.create_tag(tag_name: tag_name)!
    assert repo.is_tag_exists(tag_name: tag_name)! == true

    repo_setup.clean()!
}

// Test checkout to the base branch.
//
// Steps:
// - Setup repository directory.
// - Clone the repository.
// - Create a new branch and checkout.
// - Verify the branch was checked out.
// - Checkout back to the base branch.
// - Verify the branch was checked out.
[test]
fn test_checkout_to_base_branch() {
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
    
    repo.checkout(branch_name: branch_name, pull: false)!
    assert repo.status_local.branch == branch_name

    repo.checkout(checkout_to_base_branch: true, pull: true)!
    assert repo.status_local.branch != branch_name

    repo_setup.clean()!
}