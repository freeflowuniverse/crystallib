
```js

!!core.context_set name:'mybooks' cid:'000' interactive:false fsdb_encrypted:true coderoot:'~/hero/code'

!!core.snippet name:codeargs pull:true reset:false


!!books.config 	coderoot:'~/hero/code'
	buildroot:'~/hero/var/mdbuild'
	publishroot:'~/hero/www/info'
	install:true
	reset:false

```

