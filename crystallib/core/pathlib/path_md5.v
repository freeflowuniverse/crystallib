module pathlib

import crypto.md5
import os
import io
import encoding.hex
import freeflowuniverse.crystallib.ui.console

// return in hex format
pub fn (mut path Path) md5hex() !string {
	mut r := path.md5()!
	return hex.encode(r)
}

// calculate md5 in reproducable way for directory as well as large file
pub fn (mut path Path) md5() ![]u8 {
	path.check_exists()!
	// console.print_header(' md5: $path.path")
	if path.cat == .file {
		mut d := md5.new()
		mut ff := os.open(path.path)!
		defer {
			ff.close()
		}
		mut buffered_reader := io.new_buffered_reader(reader: ff)
		chunk_size := 128 * 1024 // 	128KB chunks, adjust as needed
		mut buffer := []u8{len: chunk_size}
		for {
			bytes_read := buffered_reader.read(mut buffer) or {
				if err.type_name() == 'io.Eof' {
					break
				} else {
					return err
				}
			}
			d.write(buffer[0..bytes_read])!
		}
		md5bytes := d.sum([]u8{})
		return md5bytes
	} else {
		mut pl := path.list(recursive: true)!
		mut out := []string{}
		for mut p in pl.paths {
			md5bytes := p.md5()!
			out << hex.encode(md5bytes)
		}
		// now we need to sort out, to make sure we always aggregate in same way
		out.sort()
		mut d := md5.new()
		for o in out {
			md5bytes2 := hex.decode(o)!
			d.write(md5bytes2)!
		}
		md5bytes2 := d.sum([]u8{})
		return md5bytes2
	}
}
