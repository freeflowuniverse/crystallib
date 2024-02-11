## to run the manual

```bash
hero run -u https://github.com/freeflowuniverse/crystallib/blob/development/manual/readme.md -r
```

### heroscript

this is example rscript which will build the manual, above cmd can run it.    

```js

!!circle.select name:'crmanual' id:'***' 

!!knowledgetree.collections_scan
    git_root: '/tmp/code'
	git_url: 'https://github.com/freeflowuniverse/crystallib/blob/development/manual'

!!knowledgetree.book_generate
    git_root: '/tmp/code'
	name:"crystal_manual"
	git_url: 'https://github.com/freeflowuniverse/crystallib/blob/development/manual'
    // heal: false
	

!!knowledgetree.book_open name:"crystal_manual"


```