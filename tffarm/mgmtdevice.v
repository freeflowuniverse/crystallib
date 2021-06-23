module tffarm
import despiegk.crystallib.ipaddr

pub struct ManagementDevice {
pub mut:
	ipaddr ipaddr.IPAddress
	login string
	passwd string
	//TODO:what else do we need to know?
	cat MgmtDevType
}

//which types do we support, add them
pub enum MgmtDevType {
	ipmi
}

pub fn (mut mgmt ManagementDevice) ping() bool {
	if ipaddr.ping() == false {
		return false
	}
	//TODO: implement a ping using IPMI or other
	return true
}

// check if well formed
pub fn (mut mgmt ManagementDevice) running() ?bool {
	//TODO: implement following type what to do, e.g. use ipmi tools to check if its running, ...

}


// check if well formed
pub fn (mut mgmt ManagementDevice) start() ? {
	//TODO: implement following type what to do, e.g. use ipmi tools to start, ...

}

//only requests from TF explorer will be allowed comes in through RMB
pub fn (mut mgmt ManagementDevice) stop() ? {
	//TODO: implement following type what to do, e.g. use ipmi tools to start, ...

}

pub fn (mut mgmt ManagementDevice) reboot() ? {
	mgmt.stop()
	mgmt.start()

}



pub fn (mut farm TFFarm) manage() ? {
	//listen to RMB to get requests for reboot, start, stop, running...
}
