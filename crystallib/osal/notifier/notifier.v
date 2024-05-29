module notifier

import os.notify
import os
import time
import freeflowuniverse.crystallib.ui.console

pub struct Notifier {
pub mut:
	name string
}

// TODO: its not working

pub fn new() !Notifier {
	mut n := notify.new()!
	mut f := os.open('/Users/despiegk1/code/github/freeflowuniverse/crystallib/osal/examples/download/download_example.v')!
	f.close()
	// how can we know the filedescriptors of what we need?
	fid := f.fd
	for i in 0 .. 1000000 {
		n.add(fid, .write, .edge_trigger)!
		events := n.wait(time.Duration(time.second * 100))
		console.print_debug(events)
		time.sleep(time.Duration(time.second * 1))
	}
	return Notifier{}
}
