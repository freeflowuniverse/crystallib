module knowledgetree

import freeflowuniverse.crystallib.osal
// import freeflowuniverse.crystallib.baobab.context
import log

pub fn new( name string) !Tree {
	level := match osal.env_get_default('KNOWLEDGETREE_LOG_LEVEL', 'INFO') {
		'DEBUG' {
			log.Level.debug
		}
		else {
			log.Level.info
		}
	}
	mut t := Tree{
		name: name
		// context: c
		logger: log.Log{
			level: level
		}
	}
	t.init()! // initialize mdbooks embed logic
	return t
}
