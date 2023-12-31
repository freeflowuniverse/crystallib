
```js

!!core.context_set name:'mybooks' cid:'000' interactive:false fsdb_encrypted:true coderoot:'~/hero/code'

!!snippet name:codeargs pull:true reset:false

!!snippet name:test color:red

!!include url:'https://github.com/freeflowuniverse/crystallib/tree/development/examples/mdbook/books_to_include1' 


!!books.configure 	coderoot:'~/hero/code'
	buildroot:'~/hero/var/mdbuild'
	publishroot:'~/hero/www/info'
	install:true
	reset:false

```

