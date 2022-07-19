module main

import vweb



struct App {
	vweb.Context
}

fn main() {
    vweb.run(&App{}, 8080)
}
