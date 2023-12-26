module console
import freeflowuniverse.crystallib.core.texttools

__global (
	consoles map[string]&UIConsole
)


pub struct UIConsole {
pub mut:
	x_max int = 80
	y_max int = 60
	prev_lf bool
	prev_title bool
	prev_item bool
}

pub fn (mut c UIConsole) reset() {
	c.prev_lf=false
	c.prev_title=false
	c.prev_item=false
}

pub fn (mut c UIConsole) status()string {
	mut out:="status: "
	if c.prev_lf{
		out+="L "
	}
	if c.prev_title{
		out+="T "
	}
	if c.prev_item{
		out+="I "
	}
	return out.trim_space()
}


pub fn new() UIConsole {
	return UIConsole{}
}

fn init(){
	mut c:=UIConsole{}
	consoles["main"] = &c
}

fn get()&UIConsole{
	return consoles["main"] or {panic("bug")}
}

fn trim(c_ string)string{
	c:=texttools.remove_double_lines(c_)
	return c
}

//line feed
fn lf(){
	mut c:=get()
	if c.prev_lf{
		return
	}
	print("\n")
	c.prev_lf=true
}
