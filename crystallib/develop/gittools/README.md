# Git Repository Management with Gittools

This project demonstrates the use of the `gittools` and `osal` modules from the `freeflowuniverse/crystallib` library to automate basic Git operations such as cloning a repository, creating branches, committing changes, and pushing them to a remote repository.

Features:

- Cloning or retrieving an existing repository.
- Creating and checking out new branches.
- Detecting file changes, adding them to staging, and committing.
- Pushing changes to a remote repository.
- Pulling changes from a remote repository.

### Example Workflow

The following example workflow is included in the script:

```v
// Initializes the Git structure.
import freeflowuniverse.crystallib.develop.gittools

coderoot := '~/code'
mut gs_default := gittools.new(coderoot: coderoot)!

// Retrieve the repository or clone it if necessary.
mut repo := gs_default.get_repo(name: 'repo3')!

// Create a new branch and a Python file with the current Unix timestamp in the name.
runtime := time.now().unix()
branch_name := "testing_${runtime}"
repo_path := repo.get_path()!
file_name := create_new_file(repo_path)!

// Create a new branch, checkout, add changes, commit, and push.
repo.branch_create(branch_name: branch_name, checkout: false)!
repo.checkout(branch_name: branch_name, pull: false)!

if repo.has_changes() {
    repo.add_changes()!
    repo.commit(msg: 'feat: Added ${file_name} file.')!
    repo.push()!
}

// Checkout back to the base branch and pull changes.
repo.checkout(checkout_to_base_branch: true, pull: true)!

// Create tag from the base branch
repo.tag_create(tag_name: tag_name)!
```

## Tests

The project includes several unit tests to ensure that the functionality works correctly.

To run the tests, use the following command in the project root:

```bash
v -enable-globals test crystallib/develop/gittools/tests/branches_tags_test.v 
```

**PS: This command will only run the `branches_tags_test` file. You must change the filename if you want to run a different file.**
> Running all tests simultaneously is not currently available because Vlang does not support running all tests in multiple threads.

This will run all the test cases and provide feedback on whether they pass or fail.

## Notes

- This project is highly dependent on proper configuration of Git in your environment.
- Ensure that SSH keys or access tokens are properly set up for pushing and pulling to/from the remote repository.
