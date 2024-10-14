module tests

import gittools
import freeflowuniverse.crystallib.core.base
import os

fn setup() ! {
    // Setup Redis or any required state before the test
    mut c := base.context()!
    mut redis := c.redis()!
    redis.flushall()! // Clear Redis cache

    // Ensure the temporary directories exist
    os.mkdir_all('/tmp/code/github/Ay-User')!
}

fn teardown() {
    // Clean up after tests if needed
    os.rmdir_all('/tmp/code/github/Ay-User') or {}
}

fn test_gitstructure_initialization() ! {
    // Test initializing a GitStructure
    coderoot := '/tmp/code/github/Ay-User'
    // os.mkdir_all(coderoot)! // Ensure the coderoot directory exists
    mut git_structure := gittools.getset(gittools.GitStructureConfig{
        coderoot: coderoot
    }) or {
        assert false, 'Error initializing GitStructure: ${err}'
        return
    }

    // Verify the structure is correctly initialized
    assert git_structure.config.coderoot == coderoot
    assert git_structure.key != '' // A key should be generated
}

fn test_code_get_from_url() ! {
    // Test cloning a repository from a URL
    repo_url := 'https://github.com/vlang/v.git'
    coderoot := '/tmp/code/github/Ay-User'
    os.mkdir_all(coderoot)! // Ensure the directory exists

    args := gittools.CodeGetFromUrlArgs{
        coderoot: coderoot
        url: repo_url
        branch: 'master'
        pull: true
    }

    result := gittools.code_get(args) or {
        assert false, 'Failed to clone the repository: ${err}'
        return
    }

    assert os.exists(result), 'The repository should be cloned to $result'
}

// fn test_repo_status_needs_commit() ! {
//     // Test if a repo needs commit (mocked)
//     coderoot := '/tmp/git_test_status'
//     repo_url := 'https://github.com/vlang/v.git'
//     os.mkdir_all(coderoot)! // Ensure the directory exists

//     args := gittools.CodeGetFromUrlArgs{
//         coderoot: coderoot
//         url: repo_url
//         pull: true
//     }

//     // Clone the repository first
//     gittools.code_get(args) or {
//         assert false, 'Failed to clone the repository: ${err}'
//         return
//     }

//     // Load GitStructure
//     mut git_structure := gittools.getset(gittools.GitStructureConfig{
//         coderoot: coderoot
//     }) or {
//         assert false, 'Error loading GitStructure: ${err}'
//         return
//     }

//     // Retrieve the repository and check its status
//     mut repo := git_structure.repo_get(gittools.ReposGetArgs{
//         name: 'v'
//     }) or {
//         assert false, 'Error retrieving the repository: ${err}'
//         return
//     }

//     // Modify the repository to trigger a commit need
//     os.write_file('${repo.get_path()!}/README.md', 'Test change') or {
//         assert false, 'Failed to modify the repo: ${err}'
//         return
//     }

//     assert repo.need_commit()!, 'Repository should need a commit after modification'
// }

// fn test_repo_push_pull_actions() ! {
//     // Mock test for repository push and pull (we won't perform actual git commands here)
//     coderoot := '/tmp/git_test_actions'
//     repo_url := 'https://github.com/vlang/v.git'
//     os.mkdir_all(coderoot)! // Ensure the directory exists

//     args := gittools.CodeGetFromUrlArgs{
//         coderoot: coderoot
//         url: repo_url
//         pull: true
//     }

//     gittools.code_get(args) or {
//         assert false, 'Failed to clone the repository: ${err}'
//         return
//     }

//     mut git_structure := gittools.getset(gittools.GitStructureConfig{
//         coderoot: coderoot
//     }) or {
//         assert false, 'Error loading GitStructure: ${err}'
//         return
//     }

//     mut repo := git_structure.repo_get(gittools.ReposGetArgs{
//         name: 'v'
//     }) or {
//         assert false, 'Error retrieving the repository: ${err}'
//         return
//     }

//     // Perform pull action
//     repo.pull(gittools.ActionArgs{}) or {
//         assert false, 'Failed to pull the repository: ${err}'
//         return
//     }

//     // Perform commit and push (mocked commit message)
//     repo.commit(gittools.ActionArgs{
//         msg: 'Test commit'
//     }) or {
//         assert false, 'Failed to commit changes: ${err}'
//         return
//     }

//     repo.push(gittools.ActionArgs{}) or {
//         assert false, 'Failed to push the repository: ${err}'
//         return
//     }
// }
