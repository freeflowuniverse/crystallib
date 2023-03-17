// module calc

// import freeflowuniverse.crystallib.pathlib
// import freeflowuniverse.crystallib.texttools
// import freeflowuniverse.crystallib.params
// import freeflowuniverse.crystallib.installers.mdsheet
// import v.embed_file
// import freeflowuniverse.crystallib.markdowndocs

// enum SheetsState {
// 	init
// 	initdone
// 	ok
// }

// [heap]
// pub struct SheetsConfig {
// pub mut:
// 	heal bool   = true
// 	dest string = '/tmp/mdsheet'
// }

// [heap]
// pub struct Sheets {
// pub mut:
// 	sheets          map[string]&Sheet
// 	sites          &Sites                     [str: skip] // pointer to sites
// 	state          SheetState
// 	embedded_files []embed_file.EmbedFileData // this where we have the templates for exporting a book
// 	config         SheetConfig
// }

// // make sure all initialization has been done e.g. installing mdbook
// pub fn (mut sheets Sheet) html() ! {
// 	if sheets.state == .init {
// 		// mdbook.install()!
// 		sheets.embedded_files << $embed_file('template/theme/css/xspreadsheet.css')
// 		sheets.embedded_files << $embed_file('template/theme/xspreadsheet.js')
// 		sheets.state = .initdone
// 	}
// }