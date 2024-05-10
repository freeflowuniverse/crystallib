module python

import freeflowuniverse.crystallib.osal
// import freeflowuniverse.crystallib.core.dbfs
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.installers.lang.python
import freeflowuniverse.crystallib.core.texttools
import os

pub fn (py PythonEnv) shell(name_ string) ! {
	name := texttools.name_fix(name_)
	cmd := '
	cd ${py.path.path}
	source bin/activate
	
	'
	osal.exec(cmd: cmd)!
}
