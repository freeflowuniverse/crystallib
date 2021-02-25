module vredis2

// import strconv

pub fn (mut r Redis) type_of(key string) ?KeyType {
	message := 'TYPE "$key"\r\n'
	r.socket_write(message)?
	res := r.socket_read_line()?
	return match res[1..res.len - 2] {
		'none'{
			KeyType.t_none
		}
		'string'{
			KeyType.t_string
		}
		'list'{
			KeyType.t_list
		}
		'set'{
			KeyType.t_set
		}
		'zset'{
			KeyType.t_zset
		}
		'hash'{
			KeyType.t_hash
		}
		'stream'{
			KeyType.t_stream
		}
		else {
			KeyType.t_unknown
		}
	}
}
