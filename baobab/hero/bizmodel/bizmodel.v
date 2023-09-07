

Session

import freeflowuniverse.crystallib.baobab.hero

Session

//get new herosession for business model
fn new() ! {


	mut m := bizmodel.background(mut s, path: wikipath)!

}

fn do() ! {
	mut h := hero.new(
		url: 'https://github.com/threefoldtech/vbuilders/tree/development/3builders/examples/1'
	)!
	println(h)
}
