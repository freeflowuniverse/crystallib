module redisserver

// NEED TO USE RESP2
import net
import resp2
import redisclient

pub struct RedisInstance {
pub mut:
	db map[string]string
}

struct RedisSrv {
pub mut:
	socket net.TcpListener
}

type RedisCallback = fn (resp2.RValue, mut RedisInstance) resp2.RValue

struct RedisHandler {
	command string
	handler RedisCallback
}

// https://redis.io/topics/protocol
pub fn listen(addr string, port int) ?RedisSrv {
	mut socket := net.listen_tcp(port) ?
	// socket.set_read_timeout(2 * time.second)
	return RedisSrv{
		socket: socket
	}
}

fn command_ping(input resp2.RValue, mut _ RedisInstance) resp2.RValue {
	if resp2.get_redis_array_len(input) > 1 {
		return resp2.get_redis_array(input)[1]
	}

	return resp2.r_string('PONG')
}

fn command_set(input resp2.RValue, mut srv RedisInstance) resp2.RValue {
	if resp2.get_redis_array_len(input) != 3 {
		return resp2.r_error('Invalid arguments')
	}

	key := resp2.get_redis_value_by_index(input, 1)
	value := resp2.get_redis_value_by_index(input, 2)

	srv.db[key] = value

	return resp2.r_ok()
}

fn command_get(input resp2.RValue, mut srv RedisInstance) resp2.RValue {
	if resp2.get_redis_array_len(input) != 2 {
		return resp2.r_error('Invalid arguments')
	}

	key := resp2.get_redis_value_by_index(input, 1)

	if key !in srv.db {
		return resp2.r_nil()
	}

	return resp2.r_string(srv.db[key])
}

fn command_del(input resp2.RValue, mut srv RedisInstance) resp2.RValue {
	if resp2.get_redis_array_len(input) != 2 {
		return resp2.r_error('Invalid arguments')
	}

	key := resp2.get_redis_value_by_index(input, 1)

	if key !in srv.db {
		return resp2.r_nil()
	}
	panic('implement del')
	return resp2.r_string(srv.db[key])
}

fn command_info(input resp2.RValue, mut srv RedisInstance) resp2.RValue {
	mut lines := []string{}

	lines << '# Server'
	lines << 'redis_version: vredis 0.1 custom'

	lines << '# Keyspace'
	lines << 'db0:keys=$srv.db.len,expires=0,avg_ttl=0'

	return resp2.r_string(lines.join('\r\n'))
}

fn command_select(input resp2.RValue, mut srv RedisInstance) resp2.RValue {
	if resp2.get_redis_array_len(input) != 2 {
		return resp2.r_error('Invalid arguments')
	}

	// only support db0
	if resp2.get_redis_value_by_index(input, 1) != '0' {
		return resp2.r_error('Incorrect database')
	}

	return resp2.r_ok()
}

fn command_scan(input resp2.RValue, mut srv RedisInstance) resp2.RValue {
	if resp2.get_redis_array_len(input) < 2 {
		panic('Invalid arguments')
	}

	mut root := resp2.RArray{
		values: []resp2.RValue{}
	}
	root.values << resp2.r_string('0')

	mut new_arr := resp2.RArray{
		values: []resp2.RValue{}
	}

	// we ignore cursor and reply the full list
	for k, _ in srv.db {
		new_arr.values << resp2.r_string(k)
	}

	root.values << new_arr

	return root
}

fn command_type(input resp2.RValue, mut srv RedisInstance) resp2.RValue {
	if resp2.get_redis_array_len(input) != 2 {
		return resp2.r_error('Invalid arguments')
	}

	key := resp2.get_redis_value_by_index(input, 1)

	if key !in srv.db {
		return resp2.r_nil()
	}

	// only support string value
	return resp2.r_string('string')
}

fn command_ttl(input resp2.RValue, mut srv RedisInstance) resp2.RValue {
	return resp2.r_int(0)
}

//
// socket management
//
pub fn process_input(mut client &redisclient.Redis, mut instance RedisInstance, value resp2.RValue) ?bool {
	println('Inside process')
	mut h := []RedisHandler{}

	h << RedisHandler{
		command: 'PING'
		handler: command_ping
	}
	h << RedisHandler{
		command: 'SELECT'
		handler: command_select
	}
	h << RedisHandler{
		command: 'TYPE'
		handler: command_type
	}
	h << RedisHandler{
		command: 'TTL'
		handler: command_ttl
	}
	h << RedisHandler{
		command: 'SCAN'
		handler: command_scan
	}
	h << RedisHandler{
		command: 'INFO'
		handler: command_info
	}
	h << RedisHandler{
		command: 'SET'
		handler: command_set
	}
	h << RedisHandler{
		command: 'GET'
		handler: command_get
	}
	h << RedisHandler{
		command: 'DEL'
		handler: command_del
	}
	command := resp2.get_redis_value_by_index(value, 0).to_upper()

	for rh in h {
		if command == rh.command {
			println('Process: $command')
			data := rh.handler(value, instance)
			client.write_rval(data) ?
			return true
		}
	}

	// debug
	print('Error: unknown command: ')
	for cmd in resp2.get_redis_array(value) {
		mut cmd_value := resp2.get_redis_value(cmd)
		print('cmd value >> $cmd_value ')
	}
	println('')

	err := resp2.r_error('Unknown command')
	client.write_rval(err) ?

	return false
}

pub fn new_client(mut conn net.TcpConn, mut main RedisInstance) ? {
	// create a client on the existing socket
	mut client := redisclient.Redis{
		socket: conn
	}

	for {
		// fetch command from client (process incoming buffer)
		value := client.get_response() ?
		// if err == "no data in socket" {
		// 	// FIXME
		// 	time.sleep_ms(1)
		// }
		// continue
		// }
		println('.... here')
		if value !is resp2.RArray {
			// should not receive anything else than
			// array with commands and args
			println('Wrong request from client, rejecting')
			conn.close() ?
			return
		}

		if resp2.get_redis_array(value)[0] !is resp2.RBString {
			println('Wrong request from client, rejecting rbstring')
			conn.close() ?
			return
		}
		process_input(mut client, mut main, value) ?
	}
}
