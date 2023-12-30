module play

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
// import freeflowuniverse.crystallib.core.texttools.regext
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.data.paramsparser


@[params]
pub struct PreProcessArgs {
pub mut:
	text        string @[required]
}


pub fn (mut context Context) pre_process(args_ PreProcessArgs) !string {
	mut out:=[]string{}
	mut args:=args_
	for line_ in args.text.split_into_lines() {
		line := line_.replace('\t', '    ')
		line_strip := line.trim_space()

		if line_strip.len == 0 {
			continue
		}

		if line_strip.starts_with("!!include"){
			p1:=paramsparser.new(line_strip[10..])!
			mut path:=p1.get_default("path","")!
			url:=p1.get_default("url","")!
			pull:=p1.get_default_false("pull")
			reset:=p1.get_default_false("reset")
			if path==""{
				if url==""{
					return error("need path or url for include.")
				}
				mut coderoot := ''
				if p1.exists('coderoot') {
					coderoot = p1.get_path('coderoot')!
				}

				mut gs := gittools.get(coderoot: coderoot) or {
					return error("Could not find gittools on '${coderoot}'\n${err}")
				}

				path = gs.code_get(reset:reset,pull:pull,url:url)!
			}
			
			mut p:=pathlib.get(path)
			out << p.recursive_text()!	

			continue			

		}

		if line_strip.starts_with("!!snippet"){
			mut p2:=paramsparser.new(line_strip[10..])!
			mut name:=p2.get_default("snippetname","")!
			if name==""{
				name = p2.get("name")!
			}
			p2.delete("name")
			p2.delete("snippetname")

			name=texttools.name_fix(name)

			context.snippets[name]=p2.str()

			continue

		}

		out<<line

	}
	out2 := context.snippets_apply(out.join_lines())!
	if out2.contains("!!include"){
		return context.pre_process(text:out2) !
	}
	return out2
}




//apply snippets to the text given
pub fn (mut context Context) snippets_apply(text_ string) !string {
	mut text:=text_
	for key,snippet in context.snippets{
		text=text.replace("\{${key}\}",snippet)
	}
	return text
	// vars:=regext.find_simple_vars(text)!
	// for var in vars{
	// 	text.replace("\{${var}\}",)
	// }
}