

```js

!!core.context_set name:'test' interactive:false coderoot:'~/hero/code'

!!websites.configure
    coderoot:''
	buildroot:'~/hero/var/build'
	publishroot:'~/hero/www/'
	install:true
	reset:false

!!website.define name:'flowers4peace' 

// !!website.templates_add url:'https://git.ourworld.tf/drc/www_flowers4peace/templates'

!!website.content_add url:'https://git.ourworld.tf/drc/www_flowers4peace/content'


//enable if you want to make sure you have the newest content
// !!websites.pull

!!website.generate

```