module osal

import os

pub fn (mut o Osal) file_write(path string, text string) ! {
	return os.write_file(path, text)
}
