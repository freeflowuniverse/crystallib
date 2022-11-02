module redisclient

import resp2

// send list of strings, expect OK back
pub fn (mut r Redis) send_expect_ok(items []string) ! {
	r.write_cmds(items) !
	res := r.get_string() !
	if res != 'OK' {
		println("'$res'")
		return error('did not get ok back')
	}
}

// send list of strings, expect int back
pub fn (mut r Redis) send_expect_int(items []string) !int {
	r.write_cmds(items) !
	return r.get_int()
}

pub fn (mut r Redis) send_expect_bool(items []string) !bool {
	r.write_cmds(items) !
	return r.get_bool()
}

// send list of strings, expect string back
pub fn (mut r Redis) send_expect_str(items []string) !string {
	r.write_cmds(items) !
	return r.get_string()
}

// send list of strings, expect string or nil back
pub fn (mut r Redis) send_expect_strnil(items []string) !string {
	r.write_cmds(items) !
	return r.get_string_nil()
}

// send list of strings, expect list of strings back
pub fn (mut r Redis) send_expect_list_str(items []string) ![]string {
	r.write_cmds(items) !
	return r.get_list_str()
}

pub fn (mut r Redis) send_expect_list(items []string) ![]resp2.RValue {
	r.write_cmds(items) !
	res := r.get_response() !
	return resp2.get_redis_array(res)
}
