module playbook
// import freeflowuniverse.crystallib.ui.console

// import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.core.texttools
// import freeflowuniverse.crystallib.develop.gittools
// import freeflowuniverse.crystallib.data.paramsparser

// fn (mut session Session) pre_process() ! {
// 	mut out := []string{}

// 	session.nrtimes_processed += 1

// 	if session.nrtimes_processed > 20 {
// 		console.print_debug(session.heroscript_preprocess)
// 		panic('recursive behavior pre-process out of bound')
// 	}

// 	for line_ in session.heroscript_preprocess.split_into_lines() {
// 		line := line_.replace('\t', '    ')
// 		line_strip := line.trim_space()

// 		if line_strip == '' {
// 			out << ''
// 			continue
// 		}

// 		if line_strip.starts_with("'''") || line_strip.starts_with('"""')
// 			|| line_strip.starts_with('```') {
// 			continue
// 		}

// 		if line_strip.starts_with('!!include') {
// 			p1 := paramsparser.new(line_strip[10..])!
// 			mut path := p1.get_default('path', '')!
// 			url := p1.get_default('url', '')!
// 			pull := p1.get_default_false('pull')
// 			reset := p1.get_default_false('reset')
// 			if path == '' {
// 				if url == '' {
// 					return error('need path or url for include.')
// 				}
// 				mut coderoot := ''
// 				if p1.exists('coderoot') {
// 					coderoot = p1.get_path_create('coderoot')!
// 				}
// 				// console.print_debug("gittools in $coderoot: can take a while to load if first time.")
// 				mut gs := gittools.get(coderoot: coderoot) or {
// 					return error("Could not load gittools on '${coderoot}'\n${err}")
// 				}

// 				path = gs.code_get(reset: reset, pull: pull, url: url)!
// 			}

// 			mut p := pathlib.get(path)
// 			out << p.recursive_text()!
// 			continue
// 		}

// 		if line_strip.contains('!!include') {
// 			return error('cannot have include in text (e.g. commented), which is not at start of line. \n${line_strip}')
// 		}

// 		if line_strip.starts_with('!!snippet') {
// 			mut p2 := paramsparser.new(line_strip[10..])!
// 			mut name := p2.get_default('snippetname', '')!
// 			if name == '' {
// 				name = p2.get('name')!
// 			}
// 			p2.delete('name')
// 			p2.delete('snippetname')

// 			name = texttools.name_fix(name)

// 			session.context.snippets[name] = p2.heroscript().trim_space()

// 			continue
// 		}
// 		out << line
// 	}
// 	session.heroscript_preprocess = out.join_lines()
// 	session.snippets_apply()!

// 	if session.check_for_further_process() {
// 		session.pre_process()!
// 	}
// }

// fn (mut session Session) check_for_further_process() bool {
// 	if session.heroscript_preprocess.contains('!!include') {
// 		return true
// 	}
// 	for line in session.heroscript_preprocess.split_into_lines() {
// 		line_strip := line.trim_space()
// 		if line_strip.starts_with("'''") || line_strip.starts_with('"""')
// 			|| line_strip.starts_with('```') {
// 			return true
// 		}
// 	}
// 	return false
// }

// // apply snippets to the text given
// fn (mut session Session) snippets_apply() ! {
// 	for key, snippet in session.context.snippets {
// 		session.heroscript_preprocess = session.heroscript_preprocess.replace('{${key}}',
// 			snippet)
// 	}
// }
