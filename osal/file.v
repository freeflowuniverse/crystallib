module osal

import os

pub fn file_write(path string, text string) ! {
	return os.write_file(path, text)
}


pub fn file_read(path string) !string {
	return os.read_file(path)
}
