module main
import despiegk.crystallib.redisclient
import time

fn conn(c int){
	mut redis := redisclient.get_local_new()  or { panic(err.str()+"\n"+c.str())}
	redis.set('test', 'some data')   or { panic("set"+err.str()+"\n"+c.str())}
	redis.get('test')  or{ panic("get"+err.str()+"\n"+c.str())}
}

fn redistest() ? {

	mut threads := []thread{}

	for c in 0..10000{
		//even if going slower does not work?
		time.sleep(100*time.millisecond)
		println(c)
		threads << go conn(c)
	}
	threads.wait()

	println("TEST OK")

}

fn main() {
	redistest() or { panic(err) }
}
