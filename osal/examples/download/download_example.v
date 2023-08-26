module main

import freeflowuniverse.crystallib.osal { download }

fn do() ! {

	mut p:=download(url:'https://cdnjs.cloudflare.com/ajax/libs/echarts/5.4.3/@name',
		name:'echarts.min.js'
		reset:false
		dest:'/tmp/@name'
		minsize_kb:1000
		maxsize_kb:5000
		)!

	println(p)
		
}

fn main() {
	do() or { panic(err) }
}
