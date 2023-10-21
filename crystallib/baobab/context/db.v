module context

import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.data.ourtime
import freeflowuniverse.crystallib.clients.redisclient
import freeflowuniverse.crystallib.core.texttools


[heap]
pub struct CircleDB {
pub mut:
	sessions map[string]Session
	contexts map[string]Context
}

