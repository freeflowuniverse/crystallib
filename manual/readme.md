## to run the manual

```bash
hero run -u https://github.com/freeflowuniverse/crystallib/blob/development/manual/readme.md -r
```

### 3script

this is example rscript which will build the manual, above cmd can run it.    

```js

!!circle.select name:'crmanual' id:'***' 

!!knowledgetree.collections_scan
	git_url: ' https://github.com/freeflowuniverse/crystallib/blob/development/manual'

!!knowledgetree.book_generate
	name:"crystal_manual"
	git_url: ' https://github.com/freeflowuniverse/crystallib/blob/development/manual'
    // heal: false
	

!!knowledgetree.book_open name:"crystal_manual"


```