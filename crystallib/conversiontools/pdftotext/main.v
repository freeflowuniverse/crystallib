module main

import os
import flag

fn convert_to_text(path string, dst string) !os.Result {
	if !os.exists(path) {
		return error("${path} doesn't exist")
	}
	path_clean := path.replace(' ', '\\ ')
	dst_clean := dst.replace(' ', '\\ ')
	println('pdftotext ${path_clean} ${dst_clean}')
	res := os.execute('pdftotext ${path_clean} ${dst_clean}')
	return res
}

fn read_as_text(path string) !string {
	file_name := path.split('/').last()
	dst := '/tmp/${file_name}.txt'
	res := convert_to_text(path, dst)!
	if res.exit_code != 0 {
		return error('could not convert ${path} to text')
	}
	content := os.read_file(dst)!
	return content
}

fn list_dir(path string) ![]string {
	files_list := os.ls(path)!
	return files_list
}

fn main() {
	mut files := map[string]string{}

	mut fp := flag.new_flag_parser(os.args)
	fp.application('Pdf to text')
	fp.version('v0.0.1')
	fp.skip_executable()
	dir_path := fp.string('path', `p`, '', 'dir path where we need to convert pdf to text')
	if !os.is_dir(dir_path) {
		panic('please provide an existing dir')
	}
	files_list := os.ls(dir_path)!
	for file in files_list {
		if file.len > 4 && file[file.len - 3..] == 'pdf' {
			content := read_as_text('${dir_path}/${file}') or {
				println(err)
				continue
			}
			files[file] = content
		}
	}
}
