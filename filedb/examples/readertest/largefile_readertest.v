module main
import os
import io
import benchmark
import time
const testpath="/tmp/test"

fn find_item(a string) !string{

	mut ff:=os.open(testpath)!

	mut buffered_reader:=io.new_buffered_reader(reader:ff,cap:1*1024)
	mut stdout := os.stdout()

	defer {
		ff.close()
	}

	for {
		mut r:=buffered_reader.read_line() or {break}
		// println(r)
		// println(buffered_reader.end_of_stream())
		if r.match_glob(a){
			return r
		}
	 	// time.sleep(1 * time.millisecond)
	}

	return error("could not find: $a")

}

fn copy_to_stdout(){

	mut ff:=os.open(testpath)or {panic(err)}

	mut buffered_reader:=io.new_buffered_reader(reader:ff,cap:1024*1024)
	mut stdout := os.stdout()
	io.cp(mut buffered_reader, mut stdout) or {return}
}


fn find_benchmark(nr int) {

	counter := 1000

	mut bmark := benchmark.new_benchmark()

	for i in 0..counter{
		find_item("*some line with a nr: ${nr-100}")  or {panic(err)}
		bmark.ok()
	}

	bmark.stop()

	nritems:=1000*counter/bmark.total_duration()
	println("nr of items per sec find: $nritems")		


	// time.sleep(1000 * time.millisecond)

	// copy_to_stdout()
	


}


fn main() {

	counter:=5000

	if os.exists(testpath){
		os.rm(testpath)!
	}
	

	mut ff:=os.open_append(testpath)!

	mut bmark := benchmark.new_benchmark()

	for i in 0..counter{
		ff.write_string("some line with a nr: $i\n")!
		bmark.ok()
	}

	bmark.stop()

	nritems:=1000*counter/bmark.total_duration()
	println("nr of items per sec: $nritems")		


	// time.sleep(1000 * time.millisecond)

	// copy_to_stdout()
	

	// find_item("*some line with a nr: 449")  or {panic(err)}

	find_benchmark(counter)
}


