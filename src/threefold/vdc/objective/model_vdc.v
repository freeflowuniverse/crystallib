module vdc
import log

pub struct VDC{
pub mut:
	name string
	description string
	vms []VM
	logger log.Logger
}