
```js

!!books.configure
	buildroot:'/tmp/mdbook/build'
	publishroot:'/tmp/mdbook/publish'
	install:true
	reset:false


!!book.generate name:'testinclude' title:'Test For Includes'
        path:'~/code/github/freeflowuniverse/crystallib/crystallib/data/doctree/testdata/collections/includetest'


!!doctree.add path:'~/code/github/freeflowuniverse/crystallib/crystallib/data/doctree/testdata/collections/includetest'

```


