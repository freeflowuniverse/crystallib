
```js

!!knowledgetree.collections_scan
	git_url: 'https://github.com/freeflowuniverse/crystallib/tree/development/examples/knowledgetree/data/smallbook'
	git_root: '/tmp/codebook'
    // git_reset: true

!!knowledgetree.book_generate
	name:"smallbook"
	git_url: 'https://github.com/freeflowuniverse/crystallib/tree/development/examples/knowledgetree/data/smallbook'
	git_root: '/tmp/codebook'
    heal: false
	// git_reset: true
	

!!knowledgetree.book_open name:"smallbook"


```