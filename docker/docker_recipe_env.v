module docker

import freeflowuniverse.crystallib.builder

[params]
pub struct EnvArgs {
pub mut:
	env string
}

pub struct EnvItem {
pub mut:
	env    []EnvPart
	recipe &DockerBuilderRecipe [str: skip]
}

pub struct EnvPart {
pub mut:
	name  string
	value string
}

// to do something like: 'FROM alpine:latest'
pub fn (mut b DockerBuilderRecipe) add_env(args EnvArgs) ! {
	mut item := EnvItem{
		recipe: &b
	}
	for mut line in args.env.split_into_lines() {
		line = line.trim_space()
		if line == '' {
			continue
		}
		if !line.contains('=') {
			return error('each line in env needs to have =, now ${args.env} in \n ${b}')
		}
		splitted := line.split('=')
		// if splitted.len != 2 {
		// 	return error('each line in env needs to have 1x =, now ${args.env} in \n ${b}')
		// }
		item.env << EnvPart{
			name: splitted[0]
			value: splitted[1]
		}
	}
	if item.env.len == 0 {
		return error('no argments in env, count is 0 in \n ${b}')
	}
	b.items << item
}

pub fn (mut i EnvItem) check() ! {
	// nothing much we can do here I guess
}

pub fn (mut i EnvItem) render() !string {
	mut out := []string{}
	mut first := true
	for mut envitem in i.env {
		if first {
			out << "ENV ${envitem.name}='${envitem.value}'  \\"
			first = false
		} else {
			out << "     ${envitem.name}='${envitem.value}'  \\"
		}
	}
	mut out2 := out.join_lines()
	out2 = out2.trim_string_right('\n').trim_string_right('\\')
	return out2
}
