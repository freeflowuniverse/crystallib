module vsc

import freeflowuniverse.crystallib.osal
import log

pub fn new() !VDC {
	level := match osal.env_get_default('VDC_LOG_LEVEL', 'INFO') {
		'DEBUG' {
			log.Level.debug
		}
		else {
			log.Level.info
		}
	}
	mut vdc := VDC{
		logger: log.Log{
			level: level
		}
	}
	return vdc
}


//TODO: build up models for VDC which have support for all we required
//TODO: build the actions so from examples folder we load a full model