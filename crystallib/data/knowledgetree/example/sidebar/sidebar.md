

!!book.book_new 
		name:"testbook"
		git_root: '~/code5'
		collections_giturl: 'https://github.com/threefoldfoundation/books/tree/main/content'
		git_reset: reset
		load: true
		heal: true

!!book.collection_new	book:testbook
	git_url: 'https://github.com/threefoldfoundation/books/tree/main/content/something'


!!book.sidebar_new	book:testbook name:sidebar_main
!!book.topbar_new	book:testbook name:topbar_main

!!book.sidebar_page_add	sidebar:sidebar_main page:'funny_Comparison' label:'funny comparison'

