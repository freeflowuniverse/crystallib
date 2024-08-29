module prometheus

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.clients.httpconnection
import freeflowuniverse.crystallib.sysadmin.startupmanager
import os
import time

@[params]
pub struct InstallArgs {
pub mut:
	// homedir    string
	// configpath string
	// username   string = "admin"
	// password   string @[secret]
	// secret     string @[secret]
	// title      string = 'My Hero DAG'
	reset     bool
	start     bool = true
	stop      bool
	restart   bool
	uninstall bool
	// host        string = 'localhost' // server host (default is localhost)
	// port       int = 8888
}

pub fn install(args_ InstallArgs) ! {
	install_prometheus(args_)!
	install_alertmanager(args_)!
	install_node_exporter(args_)!
	install_blackbox_exporter(args_)!
	install_prom2json(args_)!
}
