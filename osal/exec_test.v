module osal

import crypto.md5
import os

//TODO: needs to be rewritten for process

// const (
// 	cmd_create_file_and_print_content = '#!/bin/bash
// mkdir -p /tmp/testdirectory
// echo text > /tmp/testdirectory/file.txt
// cat /tmp/testdirectory/file.txt
// '
// )

// // Test that succeeds in creating a file and printing the content of that file
// fn test_exec_cmd_create_file_and_print_content() ! {
// 	res := exec(cmd: osal.cmd_create_file_and_print_content, remove_installer: false)!

// 	assert res.trim_space() == 'text'
// 	assert os.is_file('/tmp/testdirectory/file.txt')
// 	assert os.is_file('/tmp/installer.sh')

// 	// cleanup
// 	os.rmdir_all('/tmp/testdirectory')!
// }

// // Test where the command fails and we retry 2 times and it still fails
// fn test_exec_cmd_fail_and_retry() ! {
// 	res := exec(cmd: 'lsk ./', retry: 2) or {
// 		assert err.code() == 127
// 		assert err.msg().contains('Execution failed with code 127'), err.msg()
// 		assert !os.is_file('/tmp/installer.sh')
// 		return
// 	}
// 	return error('The command should fail and return an error!')
// }

// // Test where the execution takes too long and a timeout occurs
// fn test_exec_cmd_fail_due_timeout() ! {
// 	res := exec(cmd: 'sleep 10s', retry_timeout: 100) or {
// 		assert err.code() == 9999
// 		assert err.msg().contains('Execution failed timeout'), err.msg()
// 		return
// 	}
// 	return error('The command should fail and return an error!')
// }

// // Test where the command returns in an error but we ignore that error code
// fn test_exec_ignore_error_codes() ! {
// 	args := ExecArgs{
// 		cmd: 'exit 10'
// 		ignore_error_codes: [10]
// 	}

// 	mut res := exec(args)!
// }

// // Test using a cached result with a period of 10 milliseconds
// fn test_exec_cmd_done() ! {
// 	args := ExecArgs{
// 		cmd: 'echo sometext'
// 		remove_installer: false
// 		reset: false
// 		period: 10
// 	}
// 	hhash := md5.hexhash(args.cmd)
// 	mut res := exec(args)!
// 	redis_str := done_get_str('exec_${hhash}')
// 	assert redis_str.trim_space().ends_with('sometext')
// 	assert res.trim_space() == 'sometext'
// 	res = exec(args)!
// 	assert res.trim_space() == 'sometext'
// }
