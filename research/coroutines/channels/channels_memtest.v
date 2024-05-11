module main

import coroutines
import time

fn monitor(ch chan string, counter int, mut t &Test) {
	//println('2 ${m}')
	// coroutines.sleep(1 * time.second)
	t.mycounter += 1
	println('hello from monitor ${counter}')
	coroutines.sleep(5000 * time.second)
	println(t)
}

pub struct Test{
pub mut:
	mycounter int
}



fn main() {
	ch1 := chan string{}
	ch2 := chan string{}

	mut t:=Test{}
	mut c:=0
	for i in 0..1000 {
		c++
		go monitor(ch2,c,mut &t)
	}

	coroutines.sleep(4000 * time.second)

	// mut counter := 0
	// for {
	// 	counter += 1
	// 	println('hello from MAIN')
	// 	ch1 <- '${counter}'
	// 	ch2 <- '${counter}'
	// 	coroutines.sleep(4000 * time.millisecond)
	// }
	// println('done')
}
