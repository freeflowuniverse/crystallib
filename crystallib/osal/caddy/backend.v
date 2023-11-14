module caddy

// import os
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib


[heap]
pub struct Backend {
pub mut:
	addr      string = "localhost"
	port      int = 8000
	description string //always optional
}

