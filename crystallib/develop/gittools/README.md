# GitTools

`gittools` is a V language library designed to manage and interact with Git repositories efficiently. It provides functionalities to handle repository statuses, caching, and remote operations, making it an essential tool for developers working with Git.

## Features

- **Repository Management**: Easily access and manage multiple Git repositories.
- **Status Updates**: Retrieve and update the status of local and remote branches.
- **Caching**: Save and load repository data using Redis for quick access.
- **URL Generation**: Generate SSH and HTTP URLs for Git repositories.
- **Branch and Tag Handling**: Fetch branch and tag information from repositories.

## Usage

Here’s a simple example demonstrating how to use the `gittools` package:

```v
#!/usr/bin/env -S v -gc none -no-retry-compilation -cc tcc -d use_openssl -enable-globals run

import freeflowuniverse.crystallib.develop.gittools

// Reset all configurations and caches
// gittools.cachereset()!

// Initialize the Git structure with the coderoot path
mut gs_default := gittools.get(coderoot: "~/code")!

// Print all repositories in the specified coderoot
gs_default.repos_print()!

// Example of getting the path of a specific repository
mut path := gittools.code_get(
    coderoot: "~/code",
    url:      "https://github.com/despiegk/ourworld_data"
)!

// List all repositories again
gs_default.list()!

// Print the exact path of the repository
println("Repository path: $path")
```

## API Reference

### `GitRepo`

#### Methods

- `key()`: Returns a unique key for the Git repository.
- `cache_key()`: Generates a cache key for the repository.
- `cache_delete()`: Removes the repository from the cache.
- `path()`: Returns the filesystem path to the repository.
- `patho()`: Returns a rich path object for the repository.
- `redis_save()`: Saves the repository data to Redis.
- `redis_load()`: Loads the repository data from Redis.
- `status_update(args StatusUpdateArgs)`: Updates the repository status based on the provided arguments.
- `load()`: Loads repository information from the local Git configuration.
- `check()`: Validates the repository fields and path.
- `path_relative()`: Gets the relative path inside the Git structure.

### Usage Scenarios

- Use `gittools.get()` to initialize your Git structure.
- Call `repos_print()` to view all repositories managed by the library.
- Use `code_get()` to retrieve a specific repository by its URL.
