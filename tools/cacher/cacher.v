module cacher

import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.pathlib

struct Cache {
	nodes []builder.Node
}

struct CacheArgs {
	path    pathlib.Path
	name    string
	version string
	reset   bool
	nodes   []builder.Node
	hash    bool // means lock will be set and we cannot
}

pub fn cache(args CacheArgs) {
}
