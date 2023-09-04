module main

import freeflowuniverse.crystallib.pathlib
import os

const testpath4 = os.dir(@FILE) + '../../'

fn do() ! {
	mut p := pathlib.get_file('~/Music/Music', false)!
	s := p.md5hex()!
	s2 := p.size_kb()!
	println(s)
	println(s2 / 1000)
}

fn do2() ! {
	mut p := pathlib.get_file('/Users/despiegk1/Downloads/000-Our Home-20230207T032822Z-001.zip',
		false)!
	s := p.md5hex()!
	s2 := p.size_kb()!
	println(s)
	println(s2 / 1000)
}

fn main() {
	do2() or { panic(err) }
}
