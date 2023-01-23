module params

import freeflowuniverse.crystallib.texttools
import crypto.sha256
// TODO: better to use the binary one

[params]
pub struct ExportArgs {
	indent string
}

// standardised export format
pub fn (p Params) export(args ExportArgs) !string {
	mut out := []string{}
	mut keys := []string{}
	mut keys_val := map[string]string{}
	for param in p.params {
		mut key := texttools.name_fix(param.key)
		keys << key
		keys_val[key] = param.value.trim_space()
	}
	keys.sort()

	for keyname in keys {
		mut val := keys_val[keyname]
		val = val.replace('\n', '\\n')
		val = val.replace('\t', '    ')
		if val.contains(" "){
			val="'$val'"
		}
		out << '${keyname}:${val}'
	}
	mut args2:=p.args.clone()
	args2.sort()
	for arg in args2 {
		if arg.contains('\n') {
			return error('there can be no \\n in args for params')
		}
		out << arg.trim_space()
	}
	mut outstr := out.join_lines()
	if args.indent.len > 0 {
		outstr = texttools.indent(outstr, args.indent)
	}
	return outstr
}

pub fn importparams(txt string) !Params {
	return parse(txt)
}

pub fn (p Params) equal(p2 Params) !bool{
	a:=p.export()!
	b:=p2.export()!
	// println("----------------\n$a")
	// println("================\n$b")
	// println("----------------")
	return a==b
}

//returns a unique sha256 in hex, will allways return the same independent of order of params
pub fn (p Params) hexhash() !string{
	a:=p.export()!
	return sha256.hexhash(a)
}