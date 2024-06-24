module parser

import freeflowuniverse.crystallib.core.pathlib

pub fn parse(source_dir string) Actor {
	source := pathlib.get_dir(path: source_dir)!

	mut source_list := source.list()

	for mut path in source_list.paths {
		if !path.is_file() {
			continue
		}
		filename := path.name()
		if filename == 'actor.v' || filename == 'factory.v' || filename.ends_with('_test.v') {
			continue
		}
		methods << parse_methods()
	}
	code := codeparser.parse_v(seed_dir.path, recursive: true)!
}

fn parse_methods()
