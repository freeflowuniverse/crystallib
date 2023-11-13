module main
import os

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.mdbook as mdbookmgmt
import freeflowuniverse.crystallib.installers.mdbook

const infopath='/var/www/info'

fn websites_get() ! {

	mut mdbook:=mdbookmgmt.new(
			name:"datacenter",
			url:"https://github.com/ourworldventures/ourworld_books/blob/development/books/datacenter/src/SUMMARY.md"
			path:'${infopath}/datacenter'
		)
	mdbook.collection_add(name:"datacenter",url:'https://github.com/ourworldventures/ourworld_books/tree/development/content/datacenter')!
	mdbook.collection_add(name:"cyberpandemic",url:'https://github.com/threefoldfoundation/books/tree/main/content/cyberpandemic/cyberpandemic')!
	mdbook.collection_add(name:"abundance_internet",url:'https://github.com/threefoldfoundation/books/tree/main/content/abundance_internet')!
	mdbook.generate()!

	mdbook.watch(period:10)! //will every 10 sec check with git sources if changes

}

fn requirements() ! {
	// mdbook.install()!
}

fn main() {
	// requirements() or { panic(err) }
	websites_get() or { panic(err) }
}
