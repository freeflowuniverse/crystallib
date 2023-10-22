
Below you can see a snippet which demonstrates how you have a params struct with path and git_url.

- the params, makes sure you can call the function with
  - path:...
  - or git_url:... 
- if git_url is used it will get the code from git and bring it in args.path
- notice the trick where args is give immutable but then made mutable inside so we can change it later
- git_pull means we will pull the code if the directory would already exist
- git_reset means we ignore the files which are changed in the repo and will discard those local changes (dangerous)
- reload: gets the git cache to be reloaded

```golang
[params]
pub struct TreeScannerArgs {
pub mut:
	name string = 'default' // name of tree
	path string
	git_url   string
	git_reset bool
	git_root  string
	git_pull  bool
}
pub fn scan(args TreeScannerArgs) ! {
	mut args_ := args
	if args_.git_url.len > 0 {
		args.path=gittools.code_get(coderoot:args.git_root,url:args.git_url,
                pull:args.git_pull,reset:args.git_reset,reload:false)!
	}

```