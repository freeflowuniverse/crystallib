module console

import freeflowuniverse.crystallib.core.texttools

pub fn clear() {
	print('\033[2J')
}

pub fn print_header(txt string) {
	txt2 := trim(texttools.indent(txt.trim_left(' -'), ' - '))
	mut c := get()
	c.reset()
	if !c.prev_title {
		lf()
	}
	cprintln(foreground: .light_yellow, text: txt2)
	c.prev_title = true
}

pub fn print_item(txt string) {
	mut c := get()
	if c.prev_title {
		lf()
	}
	c.prev_item = true
	txt2 := trim(texttools.indent(txt, ' . '))
	cprintln(foreground: .light_green, text: txt2)
	c.reset()
}

pub fn print_debug(txt string) {
	mut c := get()
	if c.prev_title || c.prev_item {
		lf()
	}
	txt2 := trim(texttools.indent(txt, '    '))
	cprintln(foreground: .light_gray, text: txt2)
	c.reset()
}

pub fn print_debug_title(title string, txt string) {
	print_header(title)
	lf()
	mut c := get()
	if c.prev_title || c.prev_item {
		lf()
	}
	txt2 := trim(texttools.indent(txt, '    '))
	cprintln(foreground: .light_gray, text: txt2)
	c.reset()
	lf()
}

pub fn print_stdout(txt string) {
	mut c := get()
	c.status()
	if c.prev_title || c.prev_item {
		lf()
	}
	txt2 := trim(texttools.indent(txt, '    '))
	cprintln(foreground: .light_blue, text: txt2)
	c.reset()
}

pub fn print_lf(nr int) {
	for _ in 0 .. nr {
		cprintln(text: '')
	}
}

pub fn print_stderr(txt string) {
	mut c := get()
	if c.prev_title || c.prev_item {
		lf()
	}
	txt2 := trim(texttools.indent(txt, '    '))
	cprintln(foreground: .red, text: txt2)
	c.reset()
}

pub fn print_green(txt string) {
	mut c := get()
	if c.prev_title || c.prev_item {
		lf()
	}
	txt2 := trim(texttools.indent(txt, '    '))
	cprintln(foreground: .green, text: txt2)
	c.reset()
}

// import freeflowuniverse.crystallib.ui.console
// console.print_header()
