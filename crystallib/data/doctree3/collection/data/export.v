module data

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools.regext

@[params]
pub struct PageExportArgs {
pub mut:
	dest     string                      @[required]
	replacer ?regext.ReplaceInstructions
}

// save the page on the requested dest
// make sure the macro's are being executed
pub fn (mut page Page) export(args PageExportArgs) ! {
	mut dest_path := pathlib.get_file(path: args.dest, create: true)!

	// to ensure all updates are parsed correctly
	page.reparse_doc()!
	mut markdown := page.doc.markdown()!
	if mut replacer := args.replacer {
		markdown = replacer.replace(text: markdown)!
	}

	dest_path.write(markdown)!
}
