module redisserver

import net
import time

// //NEED TO USE RESP2
// import resp2

// pub struct RedisInstance {
// 	pub mut:
// 		db map[string]string
// }

// struct RedisSrv {
// 	pub mut:
// 		socket net.TcpListener
// }

// type RedisCallback = fn(RedisValue, mut RedisInstance) RedisValue

// struct RedisHandler {
// 	command string
// 	handler RedisCallback
// }

// // https://redis.io/topics/protocol
// pub fn listen(addr string, port int) ?RedisSrv {
// 	mut socket := net.listen_tcp(port)?
// 	// socket.set_read_timeout(2 * time.second)
// 	return RedisSrv{
// 		socket: socket
// 	}
// }

// //
// // commands
// //

// fn command_ping(input RedisValue, mut _ RedisInstance) RedisValue {
// 	if input.list.len > 1 {
// 		return value_success(input.list[1].str)
// 	}

// 	return value_success("PONG")
// }

// fn command_set(input RedisValue, mut srv RedisInstance) RedisValue {
// 	if input.list.len != 3 {
// 		return value_error("Invalid arguments")
// 	}

// 	key := input.list[1].str
// 	value := input.list[2].str

// 	srv.db[key] = value

// 	return value_ok()
// }

// fn command_get(input RedisValue, mut srv RedisInstance) RedisValue {
// 	if input.list.len != 2 {
// 		return value_error("Invalid arguments")
// 	}

// 	key := input.list[1].str

// 	if key !in srv.db {
// 		return value_nil()
// 	}

// 	return value_str(srv.db[key])
// }

// fn command_del(input RedisValue, mut srv RedisInstance) RedisValue {
// 	if input.list.len != 2 {
// 		return value_error("Invalid arguments")
// 	}

// 	key := input.list[1].str

// 	if key !in srv.db {
// 		return value_nil()
// 	}
// 	panic("implement del")
// 	return value_str(srv.db[key])
// }

// fn command_info(input RedisValue, mut srv RedisInstance) RedisValue {
// 	mut lines := []string{}

// 	lines << "# Server"
// 	lines << "redis_version: vredis 0.1 custom"

// 	lines << "# Keyspace"
// 	lines << "db0:keys=${srv.db.len},expires=0,avg_ttl=0"

// 	return value_str(lines.join("\r\n"))
// }

// fn command_select(input RedisValue, mut srv RedisInstance) RedisValue {
// 	if input.list.len != 2 {
// 		return value_error("Invalid arguments")
// 	}

// 	// only support db0
// 	if input.list[1].str != "0" {
// 		return value_error("Incorrect database")
// 	}

// 	return value_ok()
// }

// fn command_scan(input RedisValue, mut srv RedisInstance) RedisValue {
// 	if input.list.len < 2 {
// 		return value_error("Invalid arguments")
// 	}

// 	mut root := RedisValue{datatype: RedisValTypes.list}
// 	root.list << RedisValue{datatype: RedisValTypes.str, str: "0"}

// 	mut list := RedisValue{datatype: RedisValTypes.list}

// 	// we ignore cursor and reply the full list
// 	for k, _ in srv.db {
// 		list.list << RedisValue{datatype: RedisValTypes.str, str: k}
// 	}

// 	root.list << list

// 	return root
// }

// fn command_type(input RedisValue, mut srv RedisInstance) RedisValue {
// 	if input.list.len != 2 {
// 		return value_error("Invalid arguments")
// 	}

// 	key := input.list[1].str

// 	if key !in srv.db {
// 		return value_nil()
// 	}

// 	// only support string value
// 	return value_success("string")
// }

// fn command_ttl(input RedisValue, mut srv RedisInstance) RedisValue {
// 	return value_int(0)
// }

// //
// // socket management
// //
// pub fn process_input(mut client Redis, mut instance RedisInstance, value RedisValue) ?bool {
// 	mut h := []RedisHandler{}

// 	h << RedisHandler{command: "PING", handler: command_ping}
// 	h << RedisHandler{command: "SELECT", handler: command_select}
// 	h << RedisHandler{command: "TYPE", handler: command_type}
// 	h << RedisHandler{command: "TTL", handler: command_ttl}
// 	h << RedisHandler{command: "SCAN", handler: command_scan}
// 	h << RedisHandler{command: "INFO", handler: command_info}
// 	h << RedisHandler{command: "SET", handler: command_set}
// 	h << RedisHandler{command: "GET", handler: command_get}
// 	h << RedisHandler{command: "DEL", handler: command_del}

// 	command := value.list[0].str.to_upper()

// 	for rh in h {
// 		if command == rh.command {
// 			println("Process: $command")
// 			data := rh.handler(value, instance)
// 			client.encode_send(data)?
// 			return true
// 		}
// 	}

// 	// debug
// 	print("Error: unknown command: ")
// 	for cmd in value.list {
// 		print("$cmd.str ")
// 	}
// 	println("")

// 	err := value_error("Unknown command")
// 	client.encode_send(err)?

// 	return false
// }

// pub fn new_client(mut conn net.TcpConn, mut main RedisInstance)? {
// 	// create a client on the existing socket
// 	mut client := Redis{socket: conn}

// 	for {
// 		// fetch command from client (process incoming buffer)
// 		value := client.get_response() or {
// 			if err == "no data in socket" {
// 				// FIXME
// 				time.sleep_ms(1)
// 			}
// 			continue
// 		}

// 		if value.datatype != RedisValTypes.list {
// 			// should not receive anything else than
// 			// array with commands and args
// 			println("Wrong request from client, rejecting")
// 			conn.close()?
// 			return
// 		}

// 		if value.list[0].datatype != RedisValTypes.str {
// 			println("Wrong request from client, rejecting")
// 			conn.close()?
// 			return
// 		}

// 		process_input(mut client, mut main, value)?
// 	}
// }
