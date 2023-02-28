module markdowndocs

import pathlib

fn test_wiki1() {
	mut docs:=new(content:'
	
# TMUX

tmux library provides functions for managing local / remote tmux sessions

## Getting started

To initialize tmux on a local or [remote node](mysite:page.md), simply build the [node](defs:node.md), install tmux, and run start

- test1
- test 2
    - yes
	- no

### something else
	
	')!

	println(docs)
	
	//TODO: doesn't work properly yet, many mistakes

	//TODO: need to test wiki input vs wiki output, so it renders properly, we need to do quite some more tests for this

	panic('error, should not get here')
}


