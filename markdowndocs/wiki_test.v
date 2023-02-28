module markdowndocs

import pathlib

fn test_wiki1() {
	content := '
	
# TMUX

tmux library provides functions for managing local / remote tmux sessions

## Getting started

To initialize tmux on a local or [remote node](mysite:page.md), simply build the [node](defs:node.md), install tmux, and run start

- test1
- test 2
    - yes
	- no

### something else
	
	'
	mut docs := new(content:content)!

	
	//TODO: doesn't work properly yet, many mistakes

	//TODO: need to test wiki input vs wiki output, so it renders properly, we need to do quite some more tests for this
	println("WIKI is: ${docs.wiki()}")
	assert content == docs.wiki() 

}


