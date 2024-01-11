module screen

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.texttools
// import freeflowuniverse.crystallib.screen
import os

@[heap]
pub struct ScreensFactory {
pub mut:
	screens  map[string]&Screen
}

@[params]
pub struct ScreensNewArgs {
	reset bool
}

// return screen instance
pub fn new(args ScreensNewArgs) !ScreensFactory {
	mut t := ScreensFactory{
	}
	t.scan(args.reset)!
	if args.reset{
		t.reset()!
	}
	return t
}

// loads screen screen, populate the object
pub fn (mut self ScreensFactory) scan(reset bool) ! {
	self.screens = map[string]&Screen{}
	res:=os.execute("screen -ls")
	if res.exit_code>1{
		return error("could not find screen or other error, make sure screen is installed.\n${res.output}")
	}
	if res.output.contains("No Sockets found"){
		return
	}
	//there is stuff to parses
	
	res1:=texttools.remove_empty_lines(res.output)
		.split_into_lines()
		.filter(it.starts_with(" ") || it.starts_with("\t") )
		.join_lines()
	mut res2:=texttools.to_list_map("pre,state",res1,"").map(find_screen(it))
	for mut item in res2{
		if item.name in self.screens{
			if reset{
				item.kill()!
				continue
			}else{
				return error("duplicate screen with name: ${item.name}")
			}
			
		}
		self.screens[item.name]=&item
	}

	
}

pub struct ScreenAddArgs {
pub mut:
	name string [requred]
	cmd string
	reset bool
	start bool = true
	attach bool
}

pub fn (mut self ScreensFactory) get(name string)?&Screen {
	// println("get ${name}")
	// println(self)
	if name in self.screens{
		// println("found screen")
		return self.screens[name] or {panic("bug")}
	}
	return none
}

pub fn (mut self ScreensFactory) exists(name string)bool {
	if name in self.screens{
		return true
	}
	return false
}


// print list of screen screens
pub fn (mut self ScreensFactory) add(args_ ScreenAddArgs)!&Screen {
	mut args:=args_
	if args.cmd==""{
		args.cmd = "/bin/bash"
	}	
	mut screen:= self.get(args.name) or {
		mut s:=Screen{
			name:args.name
			cmd:args.cmd
		}
		&s
	}
	if args.reset{
		screen.kill()!
	}
	if args.start{
		screen.start()!
	}
	if args.attach{
		screen.attach()!
	}	
	self.scan(false)!
	return screen

}


// print list of screen screens
pub fn (mut self ScreensFactory) reset()! {
	for _, mut screen in self.screens {
		screen.kill()!
	}
	self.scan(false)!
}


pub fn (mut self ScreensFactory) str() string {
	if self.screens.len==0{
		return "No screens found."
	}
	mut out := '# Screens\n'
	for key,s in self.screens {
		out += '${*s}\n'
	}
	return out
}
