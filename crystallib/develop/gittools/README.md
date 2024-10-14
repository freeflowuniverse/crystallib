### README.md

# GitTools for VLang

GitTools is a powerful Git management library written in VLang, designed to help developers manage Git repositories efficiently. This library provides functionalities such as cloning, pulling, pushing repositories, managing multiple Git structures, and caching repository information.

## Features

- Clone Git repositories using SSH or HTTP.
- Commit, push, and pull changes from repositories.
- Manage multiple Git structures with customizable settings.
- Caching using Redis for faster repository operations.
- Automatically reload and reset repositories as needed.
- Supports advanced Git operations (branches, tags, submodules).

## Installation

### Prerequisites
- **VLang**: Make sure you have VLang installed. If not, follow the [VLang installation guide](https://vlang.io/getting-started).
- **Redis**: Redis is used for caching repository information. Install Redis from [redis.io](https://redis.io/download).

### Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/gittools-vlang.git
   cd gittools-vlang
   ```

2. Build the project:
   ```bash
   v build .
   ```

3. Run tests to verify:
   ```bash
   v test .
   ```

## Usage Example

```v
import gittools

fn main() {
    // Define the Git root directory and URL
    git_root := '/path/to/git/root'
    repo_url := 'https://github.com/yourusername/yourrepository.git'

    // Initialize GitStructure and clone the repo
    args := gittools.CodeGetFromUrlArgs{
        coderoot: git_root
        url: repo_url
        branch: 'main'
        pull: true
    }

    result := gittools.code_get(args) or {
        eprintln('Error getting the repo: $err')
        return
    }

    println('Repo successfully cloned to: $result')

    // Load the GitStructure and list repositories
    mut git_structure := gittools.getset(gittools.GitStructureConfig{
        coderoot: git_root
    }) or {
        eprintln('Error loading git structure: $err')
        return
    }

    git_structure.repos_print(gittools.ReposGetArgs{}) or {
        eprintln('Error listing repositories: $err')
    }
}
```

### Detailed API Overview

#### 1. `CodeGetFromUrlArgs`
Arguments to pull a repository from a URL.

| Field            | Type     | Description                                                 |
|------------------|----------|-------------------------------------------------------------|
| `coderoot`       | `string` | Root directory for code storage.                            |
| `url`            | `string` | The Git repository URL.                                     |
| `branch`         | `string` | The branch to clone (optional).                             |
| `pull`           | `bool`   | Whether to pull the latest changes after cloning (optional).|
| `reset`          | `bool`   | Whether to reset the repository to the latest changes.      |

#### 2. `GitStructureConfig`
Configure the Git structure, providing root paths, and controlling logging and history depth.

| Field            | Type     | Description                                                 |
|------------------|----------|-------------------------------------------------------------|
| `coderoot`       | `string` | The root directory for all repositories.                    |
| `light`          | `bool`   | If true, shallow clones are used for repositories.          |
| `log`            | `bool`   | Enable or disable logging of Git commands.                  |

#### 3. `gittools.getset()`
Sets up and returns a GitStructure based on the configuration.

#### 4. `gittools.code_get()`
Clones or updates a repository based on the provided arguments.

#### 5. `gittools.repos_print()`
Prints all repositories within the GitStructure.

### Tests

To run tests:

```bash
v test .
```

The test suite ensures that the core functionalities of cloning, pulling, pushing, and repository management work as expected.

### Example Usage (As a standalone V file)
```v
import gittools

fn main() {
    // Define Git root directory and repo URL
    coderoot := '/home/user/git_repos'
    repo_url := 'https://github.com/user/myrepo.git'

    // Initialize the arguments for code_get
    args := gittools.CodeGetFromUrlArgs{
        coderoot: coderoot
        url: repo_url
        branch: 'main'
        pull: true
    }

    // Clone or pull the repository
    result := gittools.code_get(args) or {
        eprintln('Failed to get repository: $err')
        return
    }

    println('Repository cloned or updated at: $result')

    // Example of listing repositories under the GitStructure
    mut git_structure := gittools.getset(gittools.GitStructureConfig{
        coderoot: coderoot
    }) or {
        eprintln('Failed to load GitStructure: $err')
        return
    }

    git_structure.repos_print(gittools.ReposGetArgs{}) or {
        eprintln('Failed to list repositories: $err')
    }
}
```
