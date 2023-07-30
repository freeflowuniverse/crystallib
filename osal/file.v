module osal

import os

pub fn file_write(path string, text string) ! {
	return os.write_file(path, text)
}
