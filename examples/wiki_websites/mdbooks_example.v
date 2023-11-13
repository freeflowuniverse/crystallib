module main
import os

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.mdbook as mdbookmgmt
import freeflowuniverse.crystallib.osal.zola


const infopath='/var/www/info'

fn wikis_get() ! {

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

fn websites_get() ! {

	//TODO need to be fixed

	// mut sites:= mdsitemgmt.new(
	// 		path:"/tmp/mdsites"
	// 		coderoot:"/tmp/mdsites_src"
	// 		install:false
	// )!

	// mut site1:=sites.site_new(
	// 		name:"datacenter",
	// 		url:"https://github.com/ourworldventures/ourworld_sites/blob/development/sites/datacenter/src/SUMMARY.md"
	// 	)!

	// sites.watch(period:10) //will every 10 sec check with git sources if changes

}


fn requirements() ! {
	// mdbook.install()!
}

fn main() {
	requirements() or { panic(err) }
	wikis_get() or { panic(err) }
	websites_get() or { panic(err) }
}
