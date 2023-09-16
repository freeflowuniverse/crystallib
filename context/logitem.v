module context

import freeflowuniverse.crystallib.ourtime
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.params
import os


pub struct LogItem{
pub mut:
	session &Session [skip; str: skip]
	time timetools.OurTime
	cat string
	log string
}


[params]
pub struct LogArgs{
pub mut:
	cat string
	log string [required]
}


// cat & log are the arguments .
// category can be any well chosen category e.g. vm
pub fn (session Session) log(args_ LogArgs) !LogItem {
	mut args:=args_
	args.cat:=timetools.name_fix(args.cat)
	
	mut l:=LogItem{
		session:&session
		cat:args.cat
		log:args.log
		time:ourtime.now()
	}

}

