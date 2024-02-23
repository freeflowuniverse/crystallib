module initd

struct IProcessInfoRaw{
	unit string
	load string
	active string
	sub string
	description string
}

pub struct IProcessInfo{
pub mut
	unit string
	load LoadState
	active ActiveState
	sub SubState
	description string
}

pub enum LoadState{
	loaded //The unit's configuration file has been successfully loaded into memory.
	not_found //The unit's configuration file could not be found.
	error //There was an error loading the unit's configuration file.
	masked //The unit has been masked, which means it has been explicitly disabled and cannot be started.
}

pub enum ActiveState{
	active //The unit has been started successfully and is running as expected.
	inactive	// The unit is not running.
	activating // The unit is in the process of being started.
	deactivating // The unit is in the process of being stopped.
	failed// The unit tried to start but failed.
}

//This provides more detailed information about the unit's state, often referred to as the "sub-state". This can vary significantly between different types of units (services, sockets, timers, etc.)
pub enum SubState{
	running // The service is currently running.
	exited // The service has completed its process and exited. For services that do something at startup and then exit (oneshot services), this is a normal state.
	failed // The service has failed after starting.
	waiting // The service is waiting for some condition to be met.
}


pub fn process_info() !IProcessInfo {
	cmd := 'systemctl list-units --type=service --no-pager -o json-pretty '
	res := os.execute(cmd)
	if res.exit_code > 0 {
		return error('could not execute: ${cmd}')
	}
	items:=json.decode([]IProcessInfoRaw, res.output)
	for item in items{
		mut unit:=
		match item.load{
			"loaded" {}
			"not-found" {}
			"error" {}
			"masked" {}
			else{return error("could not find right load state for systemd")}
		}
		name := texttools.name_fix(item.unit)
		initdobj.processes[name] = pobj
	}
}
