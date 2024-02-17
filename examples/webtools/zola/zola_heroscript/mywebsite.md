

```js

!!context.configure
    name:'test'
    // coderoot:'/tmp/code'
    // interactive:true

!!websites.configure
	buildroot:'~/hero/var/build'
	publishroot:'~/hero/www/'
	install:true
	reset:false

// !!website.define name:'mywebsite' title:'life is good' 

// !!website.template_add url:'https://github.com/freeflowuniverse/webcomponents/tree/main/zola'

// !!website.content_add url:'https://git.ourworld.tf/drc/www_flowers4peace/src/branch/master/content'

// //add collections to the website
// !!website.doctree_add url:'https://git.ourworld.tf/drc/www_flowers4peace/src/branch/master/content'

// !!website.pull

// !!website.generate

```