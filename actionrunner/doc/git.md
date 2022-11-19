

# GitRunner

Deal with git, only someone with admin rights can do this.

## git.init

- init's the git, there is an auto init if nothing specified
- params
    - path : is the path where the git structure is being built
    - multibranch (bool, optional): if specified the git repo's will be checked out using multiple paths
- example
    ```yaml
    !!git.link
    source:'https://github.com/ourworld-tsc/ourworld_books/tree/development/content/tanzania_feasibility/technology'
    dest:'https://github.com/threefoldfoundation/books/tree/main/books/feasibility_study_internet/src/capabilities'        
    ```

## git.stop

- no params
- removes the sshkey and stops the runner for git

## sshagent.key.load

- will remember the sshkey see [sshagent](sshagent.md), can be needed to get git to work properly, we only support ssh-key based working

## git.repo.get

- will pull the repo information, if reset the changes will be removed
- params
    - url: the url we bring in through git, the sshkey needs to be loaded 
        - e.g https://github.com/threefoldfoundation/www_examplesite/tree/development/manual  (note how the branch is in the url)
        - e.g. git@github.com:threefoldfoundation/home.git
        - e.g. https://github.com/threefoldfoundation/home/tree/master/scripts 
        - e.g. https://github.com/threefoldfoundation/home/tree/9889c8ab1e6f95144b9638b1724e71c5eb4cf770/scripts (a very specific version of the git tree)
    - name (optional)
        - if name is not given then is the name of the repo in the account
        - can overrule the name
    - pull (optional): is a bool written as 1,0,false,true (if not specified will not pull unless if it doesn't exist)
    - reset (optional): is a bool written as 1,0,false,true
- returns
    - the path where the repo was checked out


## git.repo.commit

- will commit changes, and can optionally push
- params
    - url (optional): see git.repo.get
    - name (optional): then the repo needs to be known already, if not will fail unless if url was specified
    - msg or message: the message as used when doing the commit
    - push (bool,optional): will push to remote repo if specified, if not specified is only commit
- returns
    - the path where the repo was checked out

## git.repo.delete

- will delete a repo
- params
    - url: see git.repo.commit
    - name: see git.repo.commit
- if repo doesn't exist will not do anything
- no return

## git.link

- link a subset of a git based directory into another directory
- params
    - gitsource : name of the git repo which is the source (use git.repo.get before using this)
    - gitlink : name of the git repo which will have the link (use git.repo.get before using this)
    - sourcepath: is the path inside the gitsource repository, can also be specified directly on gitsource
    - linkpath: is the path inside the gitlink repo, this is where the link will be created, can also be specified directly on gitsource
    - pull: means we will pull the gitsource (optional written as 1,0,false,true)
    - pullreset: means we will ignore changes if any in the gitsource, so they can be overwritten by the pyll
- returns
    - the path of the link
- example 1
    ```yaml
    !!git.link
    gitsource:'https://github.com/ourworld-tsc/ourworld_books/tree/development/content/tanzania_feasibility/technology'
    gitlink:'https://github.com/threefoldfoundation/books/tree/main/books/feasibility_study_internet/src/capabilities'        
    ```
- example 2 (has same result as example 1)
    ```yaml
    !!git.link
        gitsource: 'https://github.com/ourworld-tsc/ourworld_books'
        gitlink: 'https://github.com/threefoldfoundation/books'
        sourcepath: 'content/tanzania_feasibility/technology'
        linkpath: books/feasibility_study_internet/src/capabilities
    ```