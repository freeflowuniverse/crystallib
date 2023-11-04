module paramsparser

import freeflowuniverse.crystallib.core.texttools
import crypto.sha256

struct ParamExportItem {
mut:
	key       string
	txt       string // if empty then is arg
	firstline bool
	multiline bool
	isarg bool
}

// will first do the args, then the kwargs
// presort means will always come first
fn (p Params) export_helper(args_ ExportArgs) ![]ParamExportItem {
	mut args := args_

	if p.args.len > 0 && args.args_allowed == false {
		return error('args are not allowed')
	}

	mut res := []ParamExportItem{}
	mut res_delayed := []ParamExportItem{}
	mut keys := []string{}
	mut keys_val := map[string]string{}
	for param in p.params {
		mut key := texttools.name_fix(param.key)
		if key !in args.presort {
			keys << key
		}
		mut val := param.value.trim_space()
		val = val.replace('\n', '\\n')
		val = val.replace('\t', '    ')
		if val.contains(' ') {
			val = "'${val}'"
		}
		keys_val[key] = val
	}
	keys.sort()

	mut firstlinesize := 0

	if args.args_remove == false {
		mut args2 := p.args.clone()
		args2.sort()
		for mut arg in args2 {
			arg = texttools.name_fix(arg)
			res << ParamExportItem{
				key: arg
				firstline: true
				isarg: true
			}
			firstlinesize += arg.len + 1
		}
	}

	for key in args.presort.reverse() {
		keys.prepend(key) // make sure we have the presorted once first
	}

	for keyname in keys {
		mut val := keys_val[keyname]
		if val.len==0{
			continue
		}
		firstlinesize += keyname.len + val.len + 2
		mut firstline := true
		if firstlinesize > args.maxcolsize || val.len > 25 {
			firstline = false
			firstlinesize -= keyname.len + val.len + 2
		}
		if args.oneline {
			firstline = true
		}
		// println("++ $firstline $firstlinesize $val")
		mut multiline := val.contains('\\n')
		if args.multiline == false || args.oneline {
			multiline = false
		}
		if firstline {
			res << ParamExportItem{
				key: keyname
				txt: val
				firstline: firstline
				multiline: multiline
			}
		} else {
			res_delayed << ParamExportItem{
				key: keyname
				txt: val
				firstline: firstline
				multiline: multiline
			}
		}
	}
	res << res_delayed
	return res
}

[params]
pub struct ExportArgs {
pub mut:
	presort      []string
	args_allowed bool = true
	args_remove  bool
	maxcolsize   int = 120
	oneline      bool // if set then will put all on oneline
	multiline    bool = true // if we will put the multiline strings as multiline in output
	indent       string
	pre          string // e.g. can be used to insert action e.g. !!remark.define (pre=prefix on the first line)
}

// standardised export format .
// .
// it outputs a default way sorted and readable .
//```js
// presort []string //if mentioned will always put these arguments first
// args_allowed bool=true //if args are allowed
// args_remove bool
// maxcolsize int 80
// oneline bool //if set then will put all on oneline	
// multiline bool = true //if we will put the multiline strings as multiline in output
//```
pub fn (p Params) export(args ExportArgs) string {
	mut out := '${args.pre}'
	items := p.export_helper(args) or { panic('bug, should not use args.') }
	for item in items {
		if item.multiline {
			mut txt := item.txt.trim(' \'"').replace('\\n', '\n')
			out += '\n    ${item.key}:\''
			out += '\n'
			out += texttools.indent(txt, '        ')
			out += "    '"
		} else {
			if !item.firstline {
				out += '\n    '
			}
			if item.isarg{
				out += '${item.key}'
			}else{
				out += '${item.key}:${item.txt}'
			}
			if item.firstline {
				out += ' '
			}
		}
	}
	out = out.trim_right(' \n')
	if out.contains('\n') {
		out += '\n' // if its a multiline needs to make sure last is \n
	}
	if args.indent.len > 0 {
		out = texttools.indent(out, args.indent)
	}
	return out
}

pub fn importparams(txt string) !Params {
	return parse(txt)
}

pub fn (p Params) equal(p2 Params) bool {
	a := p.export()
	b := p2.export()
	// println("----------------\n$a")
	// println("================\n$b")
	// println("----------------")
	return a == b
}

// returns a unique sha256 in hex, will allways return the same independent of order of params
pub fn (p Params) hexhash() string {
	a := p.export(oneline: true, multiline: false)
	return sha256.hexhash(a)
}

// TODO: args are still wrong will show as argname1: ... instead of argname1 argname2 ...
