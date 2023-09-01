module knowledgetree

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.baobab.spawner
import log

pub fn new(mut s spawner.Spawner) !Tree {
	level := match osal.env_get_default('KNOWLEDGETREE_LOG_LEVEL', 'INFO') {
		'DEBUG' {
			log.Level.debug
		}
		else {
			log.Level.info
		}
	}
	mut t := Tree{
		spawner: s
		logger: log.Log{
			level: level
		}
	}
	t.init()! // initialize mdbooks logic
	return t
}
