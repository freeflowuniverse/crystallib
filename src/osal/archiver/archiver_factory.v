module archiver

// import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.pathlib

// struct Cache{
// 	nodes []builder.Node

// }pathlib.Path

struct ArchiverConfig {
	pathstor string
	pathmeta string
	compress bool = true
}

struct Archiver {
	pathstor pathlib.Path
	pathmeta pathlib.Path
}

pub fn new(args ArchiverConfig) !Archiver {
	if args.pathstor == '' {
		args.pathstor = '${os.home_dir}/stor/data'
	}
	if args.pathmeta == '' {
		args.pathmeta = '${os.home_dir}/stor/meta'
	}
	mut archiver := Archiver{
		pathstor: pathlib.get_dir(args.pathstor, true)!
		pathmeta: pathlib.get_dir(args.pathmeta, true)!
	}

	return archiver
}
