```js

!!website.define name:'www2_threefold' title:'Threefold Development' 

!!website.template_add url:'https://github.com/threefoldfoundation/www_threefold_io/tree/development_zola'

!!website.content_add url:'https://github.com/threefoldfoundation/www_threefold_io/tree/development_zola/content'

add collections to the website
!!website.doctree_add url:'https://github.com/threefoldfoundation/threefold_data/tree/development/content'

!!website.generate

```