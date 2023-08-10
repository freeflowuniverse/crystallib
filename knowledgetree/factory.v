module knowledgetree

import freeflowuniverse.crystallib.osal 

import log

pub fn new() !Tree {
	level := match osal.env_get_default("KNOWLEDGETREE_LOG_LEVEL", 'INFO') {
		'DEBUG' {
			log.Level.debug
		}
		else {
			log.Level.info
		}
	}
	mut t:= Tree{
		logger: log.Log{
			level: level
		}
	}
	t.init()! //initialize mdbooks logic
	return t
}
