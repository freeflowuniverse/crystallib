

```js

!!core.context_set name:'test' interactive:false coderoot:'~/hero/code'

!!websites.configure
	buildroot:'~/hero/var/build'
	publishroot:'~/hero/www/'
	install:true
	reset:false

!!website.define name:'flowers4peace' 
    url:'https://git.ourworld.tf/drc/www_flowers4peace'

//enable if you want to make sure you have the newest content
!!websites.pull

!!websites.generate

```