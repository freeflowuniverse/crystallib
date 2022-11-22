
# generic format

- the name behind !! is the name of the action
- strings can be with '' or without
- there can be space between : and the string
- bool's are represented in string form and automatically converted

the following are all alike

```yaml
!!git.link
gitsource: 'https://github.com/ourworld-tsc/ourworld_books'
gitlink: 'https://github.com/threefoldfoundation/books'
sourcepath: 'content/tanzania_feasibility/technology'
linkpath: books/feasibility_study_internet/src/capabilities
```

```yaml
!!git.link
gitsource: https://github.com/ourworld-tsc/ourworld_books
gitlink:https://github.com/threefoldfoundation/books
sourcepath: 'content/tanzania_feasibility/technology'
linkpath: books/feasibility_study_internet/src/capabilities
```

```yaml
!!git.link
    gitsource: 'https://github.com/ourworld-tsc/ourworld_books'
    gitlink: 'https://github.com/threefoldfoundation/books'
    sourcepath: 'content/tanzania_feasibility/technology'
    linkpath: books/feasibility_study_internet/src/capabilities
```

```yaml
!!git.link gitsource: 'https://github.com/ourworld-tsc/ourworld_books' gitlink: 'https://github.com/threefoldfoundation/books'
    linkpath: books/feasibility_study_internet/src/capabilities
    sourcepath: 'content/tanzania_feasibility/technology'
```

Params can be on first line, the order of the arguments do not matter