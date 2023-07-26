module osal

import os

const(
	cmd_create_file_and_print_content = '#!/bin/bash
mkdir -p /tmp/testdirectory
echo text > /tmp/testdirectory/file.txt
cat /tmp/testdirectory/file.txt
'
)

fn test_exec_cmd_create_file_and_print_content() ! {
	mut o := new()!

	res := o.exec(cmd:"${cmd_create_file_and_print_content}", remove_installer: false)!

	assert res.trim_space() == "text"
	assert os.is_file("/tmp/testdirectory/file.txt")
	assert os.is_file('/tmp/installer.sh')

	// cleanup
	os.rmdir_all("/tmp/testdirectory")!
}
