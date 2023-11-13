module main
import os

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.mdbook as mdbookmgmt
// import freeflowuniverse.crystallib.installers.mdbook

const infopath='/var/www/info'

fn websites_get() ! {

	mut books:= mdbookmgmt.new(
			path:"/tmp/mdbooks"
			coderoot:"/tmp/mdbooks_src"
			install:false
	)!

	mut book1:=books.book_new(
			name:"datacenter",
			url:"https://github.com/ourworldventures/ourworld_books/blob/development/books/datacenter/src"
		)!
	book1.collection_add(name:"datacenter",url:'https://github.com/ourworldventures/ourworld_books/tree/development/content/datacenter')!
	book1.collection_add(name:"cyberpandemic",url:'https://github.com/threefoldfoundation/books/tree/main/content/cyberpandemic/cyberpandemic')!
	book1.collection_add(name:"abundance_internet",url:'https://github.com/threefoldfoundation/books/tree/main/content/abundance_internet')!
	book1.generate()!

	books.watch(period:10) //will every 10 sec check with git sources if changes

}

fn requirements() ! {
	// mdbook.install()!
}

fn main() {
	// requirements() or { panic(err) }
	websites_get() or { panic(err) }
}
