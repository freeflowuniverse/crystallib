module heroweb

import veb
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.webserver.log
import time
import os
import net.http
import crypto.sha256

@['/assets']
pub fn (mut app App) assets(mut ctx Context) veb.Result {
	ptrs := app.db.authorized_ptrs(ctx.user_id, .read) or {
		return ctx.server_error(err.str())
	}
	docs := ptrs.map(Document{
		title: it.name.title()
		description: it.description
		url: '/view/asset/${it.name}'
		tags: it.tags
		kind: it.cat.str()
	})

	return ctx.json(docs)
}

// this endpoint serves assets dynamically
@['/asset/:paths...']
pub fn (app &App) asset(mut ctx Context, paths string) veb.Result {
	name := paths.all_before('/').all_before('?')
	infoptr := app.db.infopointers[name] or {
		return ctx.not_found()
	}


	// if infoptr.cat == .slides && !infoptr.path_content.ends_with('.pdf') {
	// 	// means png slides, return json of slides
		
		
	// 	pathlib.get_file(path: infoptr.path_content) or {
	// 		return ctx.server_error(err.str()) 
	// 	}
	// }

	file := if infoptr.cat in [.book, .website, .wiki] {
		get_webpage_file(infoptr, paths) or {
			if err.msg() == 'webpage not found' {
				return ctx.not_found()
			}
			return ctx.server_error(err.str()) 
		}
	} else if infoptr.cat == .pdf {
		pathlib.get_file(path: infoptr.path_content) or {
			return ctx.server_error(err.str()) 
		}
	} else if infoptr.cat == .slides {
		if !infoptr.path_content.ends_with('.pdf') {
				get_slide(infoptr, paths) or {
				return ctx.server_error(err.str()) 
			}
		} else {
			pathlib.get_file(path: infoptr.path_content) or {
				return ctx.server_error(err.str()) 
			}
		}
	} else {
		panic('implement')
	}

	app.log_path_access(mut ctx, name, paths) or {
		return ctx.server_error(err.str())
	}

	// Calculate the file's hash
    file_data := os.read_bytes(file.path) or { 
		return ctx.server_error(err.str())
	}
    file_hash := sha256.hexhash(file_data.bytestr())

    // Extract the client-provided hash from the query parameters
    client_hash := ctx.query['hash'] or { '' }

    // If the hashes match, return a 304 Not Modified response
    if client_hash == file_hash {
        ctx.res.set_status(.not_modified)
		return ctx.ok('')
    }

	return ctx.file(file.path)
}

// gets the html file for a webpage path
// either dir/path.html or dir/path/index.html
fn get_webpage_file(infoptr InfoPointer, paths string) !pathlib.Path {
	mut path := infoptr.path_content
	if paths == infoptr.name {
		path += '/index.html'
	} else if !paths.all_after_last('/').contains('.') {
		mut page_path := path + '${paths.all_after(infoptr.name)}.html'
		mut file := pathlib.get_file(path: page_path)!
		if !file.exists() {
			// must be other path, /path/index.html
			page_path = path + '${paths.all_after(infoptr.name)}/index.html'
		}
		path = page_path
	} else {
		path += '${paths.all_after(infoptr.name)}'
	}

	mut file := pathlib.get_file(path: path)!
	if !file.exists() {
		return error('webpage not found')
	}

	return file
}

// gets the html file for a webpage path
// either dir/path.html or dir/path/index.html
fn get_slide(infoptr InfoPointer, paths string) !pathlib.Path {
	mut path := infoptr.path_content
	path += '${paths.all_after(infoptr.name)}'
	mut file := pathlib.get_file(path: path)!
	if !file.exists() {
		return error('slide not found')
	}

	return file
}

fn (app &App) log_path_access(mut ctx Context, name string, path string) ! {
	subject := if ctx.user_id == 0 {
		ctx.req.header.get(.x_forwarded_for)!
	} else {
		ctx.user_id.str()
	}
	logger := log.new('logger.sqlite')!
	logger.new_log(log.Log{
		object: path
		timestamp: time.now() 
		subject: subject
		event: 'view path'
	})!
}

// // Utility to extract the start and end from the "Range" header
// fn parse_range(range_header string, file_size int) !(int, int) {
// 	// Expecting something like "bytes=start-end"
// 	if !range_header.starts_with("bytes=") {
// 		return error("Invalid range header")
// 	}

// 	range_str := range_header[6..].split('-')
// 	start := range_str[0].int()
// 	end := if range_str.len > 1 && range_str[1] != '' {
// 		range_str[1].int()
// 	} else {
// 		file_size - 1
// 	}

// 	if start >= file_size || end >= file_size || start > end {
// 		return error("Invalid range values")
// 	}

// 	return start, end
// }

// // Action to serve the PDF with Range support
// ['/pdf/:name']
// pub fn (mut app App) serve_pdf(mut ctx Context, name string) !veb.Result {
// 	// Path to the file (ensure proper sanitization in real-world use)

// 	infoptr := app.db.infopointers[name] or {
// 		return ctx.not_found()
// 	}

// 	mut path := pathlib.get(infoptr.path_content) 
// 	file_path := path.path

// 	// Get file size
// 	file_size := os.file_size(file_path) 

// 	// Open the file
// 	mut f := os.open(file_path) or {
// 		return ctx.server_error('500')
// 	}
// 	defer {
// 		f.close()
// 	}

// 	// Check if request contains a "Range" header
// 	range_header := ctx.req.header.get(http.CommonHeader.range) or { '' }
// 	if range_header != '' {
// 		// Handle partial content request
// 		start, end := parse_range(range_header, int(file_size)) or {
// 			// Invalid range request
// 			return ctx.server_error('416') // 416 Range Not Satisfiable
// 		}

// 		// Seek to the start of the range
// 		f.seek(start, .start) or { return ctx.server_error('500') }

// 		// Read the requested range
// 		data := f.read_bytes(end - start + 1)

// 		// Send 206 Partial Content response
// 		ctx.res.set_status(.partial_content)
// 		ctx.res.header.add(.content_range, 'bytes $start-$end/$file_size')
// 		ctx.res.header.add(.content_length, (end - start + 1).str())
// 		ctx.res.header.add(.accept_ranges, 'bytes')

// 		app.send_binary(data, 200)
// 		return veb.no_result()
// 	} else {
// 		// No Range header, send full content
// 		data := f.read_bytes(int(file_size))

// 		ctx.res.header.add(.content_length, file_size.str())
// 		ctx.res.header.add(.accept_ranges, 'bytes')

// 		app.send_binary(data, 206)
// 		return veb.no_result()
// 		// return ctx.ok(data)
// 	}
// }
// // Helper function to send binary data in the response
// pub fn (mut app App) send_binary(data []u8, status_code int) {
// 	// app.set_status(status_code, '')
// 	// // Write headers
// 	// app.send_headers()
// 	// // Write binary content directly to the connection

// 	// ctx.conn.write_ptr(&u8(data), data.len) or {}
// 	// ctx.conn.close() or {}
// }
