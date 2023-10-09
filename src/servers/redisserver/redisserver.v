module redisserver

// NEED TO USE resp
import freeflowuniverse.crystallib.clients.redisclient
import freeflowuniverse.crystallib.resp
import net
import time

pub struct RedisInstance {
pub mut:
	db map[string]string
}

pub struct RedisSrv {
pub mut:
	socket net.TcpListener
}

type RedisCallback = fn (resp.RValue, mut RedisInstance) resp.RValue

pub struct RedisHandler {
	command string
	handler RedisCallback
}

// https://redis.io/topics/protocol
pub fn listen(addr string, port int) !RedisSrv {
	mut socket := net.listen_tcp(net.AddrFamily.ip, '${addr}:${port}')!
	// socket.set_accept_timeout(2 * time.second)
	return RedisSrv{
		socket: socket
	}
}

fn command_ping(input resp.RValue, mut _ RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) > 1 {
		return resp.get_redis_array(input)[1]
	}

	return resp.r_string('PONG')
}

fn command_set(input resp.RValue, mut srv RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) != 3 {
		return resp.r_error('Invalid arguments')
	}

	key := resp.get_redis_value_by_index(input, 1)
	value := resp.get_redis_value_by_index(input, 2)

	srv.db[key] = value

	return resp.r_ok()
}

fn command_get(input resp.RValue, mut srv RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) != 2 {
		return resp.r_error('Invalid arguments')
	}

	key := resp.get_redis_value_by_index(input, 1)

	if key !in srv.db {
		return resp.r_nil()
	}

	return resp.r_string(srv.db[key])
}

fn command_del(input resp.RValue, mut srv RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) != 2 {
		return resp.r_error('Invalid arguments')
	}

	key := resp.get_redis_value_by_index(input, 1)

	if key !in srv.db {
		return resp.r_nil()
	}
	panic('implement del')
	return resp.r_string(srv.db[key])
}

fn command_info(input resp.RValue, mut srv RedisInstance) resp.RValue {
	mut lines := []string{}

	lines << '# Server'
	lines << 'redis_version: vredis 0.1 custom'

	lines << '# Keyspace'
	lines << 'db0:keys=${srv.db.len},expires=0,avg_ttl=0'

	return resp.r_string(lines.join('\r\n'))
}

fn command_select(input resp.RValue, mut srv RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) != 2 {
		return resp.r_error('Invalid arguments')
	}

	// only support db0
	if resp.get_redis_value_by_index(input, 1) != '0' {
		return resp.r_error('Incorrect database')
	}

	return resp.r_ok()
}

fn command_scan(input resp.RValue, mut srv RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) < 2 {
		panic('Invalid arguments')
	}

	mut root := resp.RArray{
		values: []resp.RValue{}
	}
	root.values << resp.r_string('0')

	mut new_arr := resp.RArray{
		values: []resp.RValue{}
	}

	// we ignore cursor and reply the full list
	for k, _ in srv.db {
		new_arr.values << resp.r_string(k)
	}

	root.values << new_arr

	return root
}

fn command_type(input resp.RValue, mut srv RedisInstance) resp.RValue {
	if resp.get_redis_array_len(input) != 2 {
		return resp.r_error('Invalid arguments')
	}

	key := resp.get_redis_value_by_index(input, 1)

	if key !in srv.db {
		return resp.r_nil()
	}

	// only support string value
	return resp.r_string('string')
}

fn command_ttl(input resp.RValue, mut srv RedisInstance) resp.RValue {
	return resp.r_int(0)
}

//
// socket management
//
pub fn process_input(mut client redisclient.Redis, mut instance RedisInstance, value resp.RValue, h []RedisHandler) !bool {
	println('Inside process')

	command := resp.get_redis_value_by_index(value, 0).to_upper()

	for rh in h {
		if command == rh.command {
			println('Process: ${command}')
			data := rh.handler(value, mut instance)
			client.write_rval(data)!
			return true
		}
	}

	// debug
	print('Error: unknown command: ')
	for cmd in resp.get_redis_array(value) {
		mut cmd_value := resp.get_redis_value(cmd)
		print('cmd value >> ${cmd_value} ')
	}
	println('')

	err := resp.r_error('Unknown command')
	client.write_rval(err)!

	return false
}

pub fn default_handler() []RedisHandler {
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

	return h
}

pub fn new_client_custom(mut conn net.TcpConn, mut main RedisInstance, h []RedisHandler) ! {
	// create a client on the existing socket
	mut client := redisclient.Redis{
		socket: conn
	}

	for {
		// fetch command from client (process incoming buffer)
		value := client.get_response()!
		// if err == "no data in socket" {
		// 	// FIXME
		// 	time.sleep_ms(1)
		// }
		// continue
		// }
		println('.... here')
		if value !is resp.RArray {
			// should not receive anything else than
			// array with commands and args
			println('Wrong request from client, rejecting')
			conn.close()!
			return
		}

		if resp.get_redis_array(value)[0] !is resp.RBString {
			println('Wrong request from client, rejecting rbstring')
			conn.close()!
			return
		}

		process_input(mut client, mut main, value, h)!
	}
}

pub fn new_client(mut conn net.TcpConn, mut main RedisInstance) ! {
	h := default_handler()
	return new_client_custom(mut conn, mut main, h)
}
