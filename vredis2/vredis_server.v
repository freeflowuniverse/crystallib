module vredis2

import net
import time

pub struct RedisInstance {
	pub mut:
		db map[string]string
}

struct RedisSrv {
	pub mut:
		socket net.TcpListener
}

type RedisCallback = fn(RValue, mut RedisInstance) RValue

struct RedisHandler {
	command string
	handler RedisCallback
}

// https://redis.io/topics/protocol
pub fn listen(addr string, port int) ?RedisSrv {
	mut socket := net.listen_tcp(port)?
	// socket.set_read_timeout(2 * time.second)
	return RedisSrv{
		socket: socket
	}
}


fn command_ping(input RValue, mut _ RedisInstance) RValue {
	if r_array_len(input) > 1 {
		return r_list(input)[1]
	}

	return return_str("PONG")
}

fn command_set(input RValue, mut srv RedisInstance) RValue {
	if r_array_len(input) != 3 {
		return return_error("Invalid arguments")
	}

	key := r_value_by_index(input,1)
	value := r_value_by_index(input,2)

	srv.db[key] = value

	return return_ok()
}

fn command_get(input RValue, mut srv RedisInstance) RValue {
	if r_array_len(input) != 2 {
		return return_error("Invalid arguments")
	}

	key := r_value_by_index(input,1)

	if key !in srv.db {
		return return_nil()
	}

	return return_str(srv.db[key])
}


fn command_del(input RValue, mut srv RedisInstance) RValue {
	if r_array_len(input) != 2 {
		return return_error("Invalid arguments")
	}

	key := r_value_by_index(input,1)

	if key !in srv.db {
		return return_nil()
	}
	panic("implement del")
	return return_str(srv.db[key])
}


fn command_info(input RValue, mut srv RedisInstance) RValue {
	mut lines := []string{}

	lines << "# Server"
	lines << "redis_version: vredis 0.1 custom"

	lines << "# Keyspace"
	lines << "db0:keys=${srv.db.len},expires=0,avg_ttl=0"

	return return_str(lines.join("\r\n"))
}

fn command_select(input RValue, mut srv RedisInstance) RValue {
	if r_array_len(input) != 2 {
		return return_error("Invalid arguments")
	}

	// only support db0
	if r_value_by_index(input,1) != "0" {
		return return_error("Incorrect database")
	}

	return return_ok()
}

fn command_scan(input RValue, mut srv RedisInstance) RValue {
	if r_array_len(input) < 2 {
		panic ("Invalid arguments")
	}

	mut root := RArray{values: []RValue{}}
	root.values << return_str("0")

	mut new_arr := RArray{values: []RValue{}}

	// we ignore cursor and reply the full list
	for k, _ in srv.db {
		new_arr.values << return_str(k)
	}

	root.values << new_arr

	return root
}

fn command_type(input RValue, mut srv RedisInstance) RValue {
	if r_array_len(input) != 2 {
		return return_error("Invalid arguments")
	}

	key := r_value_by_index(input,1)

	if key !in srv.db {
		return return_nil()
	}

	// only support string value
	return return_str("string")
}

fn command_ttl(input RValue, mut srv RedisInstance) RValue {
	return return_int(0)
}

//
// socket management
//
pub fn process_input(mut client Redis, mut instance RedisInstance, value RValue) ?bool {
	mut h := []RedisHandler{}

	h << RedisHandler{command: "PING", handler: command_ping}
	h << RedisHandler{command: "SELECT", handler: command_select}
	h << RedisHandler{command: "TYPE", handler: command_type}
	h << RedisHandler{command: "TTL", handler: command_ttl}
	h << RedisHandler{command: "SCAN", handler: command_scan}
	h << RedisHandler{command: "INFO", handler: command_info}
	h << RedisHandler{command: "SET", handler: command_set}
	h << RedisHandler{command: "GET", handler: command_get}
	h << RedisHandler{command: "DEL", handler: command_del}

	command := r_value_by_index(value,0).to_upper()

	for rh in h {
		if command == rh.command {
			println("Process: $command")
			data := rh.handler(value, instance)
			client.encode_send(data)?
			return true
		}
	}

	// debug
	print("Error: unknown command: ")
	for cmd in r_list(value) {
		mut cmd_value := r_value(cmd)
		print("$cmd_value ")
	}
	println("")

	err := return_error("Unknown command")
	client.encode_send(err)?

	return false
}

pub fn new_client(mut conn net.TcpConn, mut main RedisInstance)? {
	// create a client on the existing socket
	mut client := Redis{socket: conn}

	for {
		// fetch command from client (process incoming buffer)
		value := client.get_response() or { panic("Can't create new client") }
			// if err == "no data in socket" {
			// 	// FIXME
			// 	time.sleep_ms(1)
			// }
			// continue
		// }

		if value !is RArray {
			// should not receive anything else than
			// array with commands and args
			println("Wrong request from client, rejecting")
			conn.close()?
			return
		}

		if r_list(value)[0] !is RString {
			println("Wrong request from client, rejecting")
			conn.close()?
			return
		}

		process_input(mut client, mut main, value)?
	}
}

