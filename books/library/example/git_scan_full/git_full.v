module main

import freeflowuniverse.crystallib.books.library

// const path0 = '~/code/github/threefoldfoundation/books'

const reset = true

fn do() ! {


	mut l := library.new()
	
	mut book:=l.book_new(
		name:"testbook2"
		git_root: '~/code5'
		chapters_giturl: 'https://github.com/threefoldfoundation/books2/tree/main/content'
		git_reset: reset
		load: true
		heal: false
	)!

	println(book.chapters.len)

	if true{panic("SDSD")}

	p1:=book.page_get("funny_Comparison")!
	p2:=book.page_get("funny Comparison.md")!
	assert p1==p2

	assert p2.pathrel=='intro/funny_comparison.md'

	println(p1)

	assert book.page_exists("funny_Comparison")
	assert book.image_exists("experience_")
	assert book.image_exists("experience_.png")
	assert book.image_exists("experience.png")
	assert book.image_exists("mytwin:experience.png")
	assert book.image_exists("testbook:mytwin:experience.png")
	assert book.image_exists("testbook::experience.png")
	assert book.image_exists("mytwins:experience.png")==false

	assert l.image_exists("testbook:mytwin:experience.png")
	assert l.image_exists("testbook::experience.png")
	assert l.image_exists("testbook::experiencee.png")==false

	println("OK")


}

fn main() {
	println('ERROR IN MAIN')
	do() or { panic(err) }
}

// git reset --hard && git clean -fxd
