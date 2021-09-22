module publisher_core

import texttools
import os

pub fn (page Page) write(mut publisher &Publisher, content string) {
	mut path := page.path_get(mut publisher)
	if path.ends_with('.md') {
		path = path[..path.len - 3]
	}
	path += '.md'
	os.write_file(path, content) or { panic('cannot write, $err') }
}

pub fn (page Page) path_exists(mut publisher &Publisher) bool {
	mut path := page.path_get(mut publisher)
	if path.ends_with('.md') {
		path = path[..path.len - 3]
	}
	path += '.md'
	return os.exists(path)
}

// // will load the content, check everything, return true if ok
// pub fn (mut page Page) check(mut publisher &Publisher) bool {
// 	page.process(mut publisher) or { panic(err) }

// 	if page.state == PageStatus.error {
// 		return false
// 	}
// 	return true
// }

fn (mut page Page) error_add(error PageError, mut publisher &Publisher) {
	for error_existing in page.errors {
		if error_existing.msg.trim(' ') == error.msg.trim(' ') {
			return
		}
	}

	if page.state != PageStatus.error {
		// only add when not in error mode yet, because means check was already done
		// println(' - ERROR: $error.msg')
		page.errors << error
	} else {
		panic(' ** ERROR (2nd time): in file ${page.path_get(mut publisher)}')
	}
}

////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////

// load the page & find defs
// if it returns false, it means was already processed
pub fn (mut page Page) load(mut publisher &Publisher) ?bool {
	if page.state == PageStatus.ok {
		// means was already processed, content is available
		return false
	}

	path_source := page.path_get(mut publisher)
	page.content = os.read_file(path_source) or {
		return error('Failed to open $path_source\nerror:$err')
	}

	// loads the defs and other metadata
	page.process_metadata(mut publisher) ?
	return true
}

// process the markdown content and include other files, find links, ...
// find errors
pub fn (mut page Page) process(mut publisher &Publisher) ?bool {
	if page.state == PageStatus.ok {
		// means was already processed, content is available
		return false
	}

	page.process_lines(mut publisher) ? // first find all the links
	// println(page.content)
	// make sure we only execute this once !
	page.state = PageStatus.ok

	return true
}

struct LineProcessorState {
mut:
	nr             int
	lines_source   []string // needs to be written to the file where we loaded from, is returned as string
	lines_server   []string // the return of the process, will go back to page.content
	site           &Site
	publisher      &Publisher
	page           &Page
	changed_source bool
	changed_server bool
}

fn (mut state LineProcessorState) error(msg string) {
	mut line := ''
	if state.lines_source.len > 0 {
		line = state.lines_source[state.lines_source.len - 1]
	}
	page_error := PageError{
		line: line
		linenr: state.nr
		msg: msg
		cat: PageErrorCat.brokeninclude
	}
	state.page.error_add(page_error, mut state.publisher)
	// state.lines_source << '> **ERROR: $page_error.msg **<BR>\n\n'
	if !(state.page.name in ['sidebar', 'navbar']) {
		state.lines_server << '> **ERROR: $page_error.msg **<BR>\n\n'
		// if msg.contains("disclaimer") && state.page.name == "humanity"{
		// 	eprintln(state.page.name)
		// 	eprintln(page_error)
		// 	panic("s")
		// }
		// println(' > Error: $state.page.name:  $msg\n$page_error')
	}
	// println(page_error)
}

//change what will be given by server to the client, so not change on source
fn (mut state LineProcessorState) serverline_change(ffrom string, tto string) {
	linelast := state.lines_server.pop()
	state.lines_server << linelast.replace(ffrom, tto)
	state.changed_server = true
}

// remove the last line e.g. needed for include
fn (mut state LineProcessorState) serverline_last_pop() {
	_ := state.lines_server.pop()
	state.changed_server = true
}

fn (mut state LineProcessorState) sourceline_change(ffrom string, tto string) {
	linelast := state.lines_source.pop()
	state.lines_source << linelast.replace(ffrom, tto)
	state.changed_source = true
}

// walk over each line in the page and check for definitions
fn (mut page Page) process_metadata(mut publisher &Publisher) ? {
	mut state := LineProcessorState{
		site: &publisher.sites[page.site_id]
		publisher: publisher
		page: page
	}

	mut debug := false

	state.site = &publisher.sites[page.site_id]
	state.publisher = publisher

	// println(state.site.name + " " + state.page.name)
	// if state.site.name == 'sdk' && state.page.name.starts_with('grid_concepts') {
	// if state.page.name.starts_with("restricted_account"){
	// 	debug = true
	// 	println(page.content)
	// 	println("DEBUG")
	// }
	page_lines := page.content.split_into_lines()

	for line in page_lines {
		state.nr++
		state.lines_source << line
		linestrip := line.trim(' ')
		linestrip_trimmed := linestrip.trim(' ')
		if linestrip_trimmed.starts_with('> **ERROR') {
			// these are error messages which will be rewritten if errors are still there
			continue
		}
		if debug {
			println(' >> $line')
		}
		trimmed_line := linestrip.trim(' ')
		if trimmed_line.starts_with('!!!def') {
			macro_process(mut state, line)
		}
	}
}

// walk over each line in the page and do the link parsing on it
// will also look for definitions
// happens line per line
fn (mut page Page) process_lines(mut publisher &Publisher) ? {
	mut state := LineProcessorState{
		site: &publisher.sites[page.site_id]
		publisher: publisher
		page: page
	}

	mut debug := false

	// mut page_linked := Page{}

	// first we need to do the links, then the process_includes

	state.site = &publisher.sites[page.site_id]
	state.publisher = publisher

	// println(state.site.name + " " + state.page.name)
	// if state.page.name.starts_with("defs"){
	// // if state.site.name == 'sdk' && state.page.name.starts_with('grid_concepts') {
	// 	debug = true
	// 	println(page.content)
	// 	println("DEBUG")
	// }

	if state.site.error_ignore_check(page.name) {
		return
	}

	for line in page.content.split_into_lines() {
		// if debug {
		// 	eprintln(' >> LINE: $line')
		// }

		// the default has been done, which means the source & server have the last line
		// source is info on disk, the code
		// server is what we will serve to the world
		// now its up to the future to replace that last line or not
		state.lines_source << line

		state.nr++

		linestrip := line.trim(' ')

		if linestrip.trim(' ').starts_with('> **ERROR') {
			// these are error messages which will be rewritten if errors are still there
			continue
		}

		if linestrip.trim(' ').starts_with('!!!def ') {
			continue // ignore the line, was already processed
		}

		if macro_process(mut state, line) {
			continue
		}

		state.lines_server << line

		if linestrip.starts_with('!!!include') {
			mut params := texttools.new_params()
			mut page_name_include := linestrip['!!!include'.len + 1..]
			if debug {
				println(' >> includes-- $page_name_include')
			}

			if page_name_include.contains(' ') {
				splitted_spaces := page_name_include.split_nth(' ', 2)

				params = texttools.text_to_params(splitted_spaces[1]) or {
					state.error('cannot process include: ${page_name_include}.\n$err\n')
					continue
				}
				page_name_include = splitted_spaces[0]
			}

			// println(" -- include: '$page_name_include'")

			mut page_linked := publisher.page_find(page_name_include, state.page.id) or {
				state.error('include, cannot find page: ${page_name_include}.\n$err')
				continue
			}

			if page_linked.path_get(mut publisher) == page.path_get(mut publisher) {
				state.error('recursive include: ${page_linked.path_get(mut publisher)}\n${page.path_get(mut publisher)}')
				continue
			}

			//make sure server will publish the full page
			name_server := page_linked.name_get(mut publisher, state.site.id)
			if  name_server != page_name_include {
				// means we need to change on the server and source side
				state.serverline_change(page_name_include, name_server)
				state.sourceline_change(page_name_include, name_server)
			}
			page_linked.nrtimes_inluded++

			// make sure the page we include has been processed
			page_linked.process(mut publisher) or {
				state.error('cannot process page: ${page.name}.\n$err\n')
				continue
			}

			// do the include
			state.serverline_last_pop()
			mut content_incl := page_linked.content
			if params.exists('level') {
				minlevel := params.get_int('level') or { panic(err) }
				content_incl = texttools.markdown_min_header(content_incl, minlevel)
			}
			for line_include in content_incl.split('\n') {
				state.lines_server << line_include
			}
			continue
		}
		// DEAL WITH LINKS
		links_parser_result := link_parser(mut publisher, line,page.id)

		// there can be more than 1 link on 1 line
		for mut link in links_parser_result.links {
			mut linkname := ''

			link.check(mut publisher, mut page, state.nr, line)

			if link.state != LinkState.ok {
				state.error('link:' + link.error_msg)
				continue
			}

			if link.cat == LinkType.page {
					mut page_linked2 := link.page_source_get(mut publisher) or {
					state.error('link, cannot find page: ${link.original_link}.\n$err')
					continue
				}
				linkname = page_linked2.name_get(mut publisher, state.site.id)
			}else if link.cat == LinkType.file {
					mut file_linked2 := link.file_get(mut publisher) or {
					state.error('link, cannot find file link: ${link.original_link}.\n$err')
					continue
				}
				linkname = file_linked2.name_get(mut publisher, state.site.id)
				if !(page.id in file_linked2.usedby) {
					file_linked2.usedby << page.id
				}
			}

			if link.cat == LinkType.page || link.cat == LinkType.file {
				// only process links if page or file

				if linkname.contains(':') {
					mut sitename9, _ := name_split(linkname) or { panic(err) }
					link.site = sitename9
				}

				if link.site == '' {
					link.site = state.site.name
				}

				if debug {
					println(' >>>> process link \n$link')
					println(' >>< sitename:$state.site.name linksitename:$link.site')
					// if link.filename.contains("disclaimer"){
					// 	panic("s")
					// }				
				}

				if linkname != link.filename {
					link.filename = linkname
					link.init_(mut publisher)
				}

				if link.state == LinkState.ok {
					if link.original_get() != link.source_get(state.site.name) {
						state.sourceline_change(link.original_get(), link.source_get(state.site.name))
						println(' >> link replace: $link.original_get() -> ${link.source_get(state.site.name)}')
					}
					llink := link.server_get (mut &publisher)
					state.serverline_change(link.original_get(),llink)
					// if debug {
					// 	println(' >>>> server: $link.original_get() -> $llink')
					// }
					// if line.contains("grid_home"){
					// 	println(line)
					// 	println(link)
					// 	println(llink)
					// }						
				}
			
			}
		} // end of the walk over all links
	} // end of the line walk

	// now we need to rewrite the source & server lines
	page.content = state.lines_server.join('\n')

	if state.changed_source {
		os.write_file(page.path_get(mut publisher), state.lines_source.join('\n')) or { panic(err) }
	}
}

fn (mut page Page) title() string {
	lines := page.content.split('\n')

	for line in lines {
		line_trimmed := line.trim(' ')
		if line_trimmed.starts_with('#') {
			line_trimmed_sharp := line_trimmed.trim('#')
			line_trimmed_space := line_trimmed_sharp.trim(' ')
			return line_trimmed_space
		}
	}
	return 'NO TITLE'
}

// return a page where all definitions are replaced with link
fn (mut page Page) replace_defs(mut publisher &Publisher) ? {
	// if page.replaced {
	// 	return
	// }
	new_content := publisher.replace_defs_links(mut &page) ?

	page.content = new_content
	page.replaced = true
}


//get the page of the sidebar which is close by
pub fn (mut page Page) sidebar_page_get(mut publisher &Publisher) ?&Page{
	return publisher.page_get_by_id(page.sidebarid)
}

