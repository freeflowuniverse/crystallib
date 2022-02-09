

module main

import despiegk.crystallib.appsbox.pen


fn do()?{

	pen.app_obj_get()?

}

fn main() {

	do() or {panic(err)}

}
