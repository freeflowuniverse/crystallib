
module rmbprocessor

import freeflowuniverse.crystallib.rmbclient
import freeflowuniverse.crystallib.encoder

import json
import log
import net.http
import net.websocket
import time

//MSG <subject> <sid> [reply-to] <#bytes>␍␊[payload]␍␊
pub struct MSG {
	subject string
	sid string
	payload string
}

pub struct CONNECT_MESSAGE {
	verbose bool
	pedantic bool
	tls_required bool
	name string
	lang string
	version string
	protocol int
	echo bool
}
pub struct StreamConfig {
	name string
	subjects []string
}

pub struct ConsumerInnerConfig {
	ack_policy string
	deliver_policy string
	deliver_subject string
	durable_name string
	max_deliver int
	replay_policy string
	num_replicas int
}

pub struct ConsumerConfig {
	stream_name string
	config ConsumerInnerConfig
}

pub struct ConsumerNextMSG {
	// A duration from now when the pull should expire, stated in nanoseconds, 0 for no expiry
	expires int
	// How many messages the server should deliver to the requestor
	batch int
	// Sends at most this many bytes to the requestor, limited by consumer configuration max_bytes
    max_bytes int
	// When true a response with a 404 status header will be returned when no messages are available
    no_wait bool
	// When not 0 idle heartbeats will be sent on this interval
	idle_heartbeat int
}


[heap]
pub struct NATSClient {
pub mut:
	address string
	websocket &websocket.Client
	logger &log.Logger
}

fn (mut cl NATSClient) on_message(mut client websocket.Client, msg &websocket.Message) ! {
	message_string := msg.payload.bytestr()
	cl.logger.info("New message: <$message_string>")
	if message_string == "PING\r\n" {
		cl.send_pong()
	}
	if message_string.starts_with("INFO") {
		cl.subscribe_consumer_response()
	}

// 	MSG ORDERS.NEW 1 $JS.ACK.my_stream.my_consumer.5.7.55.1674053106828565451.0 41
// agaiiiiiiiiiiiiiiiiiiin another new order
// MSG RESPONSE 1  0


	if message_string.starts_with("MSG") {
		// MSG <subject> <sid> [reply-to] <#bytes>␍␊[payload]␍␊
		d := message_string.split("\r\n")
		data := d[0].split(" ")
		subject := data[1]
		sid := data[2]
		reply_to := data[3]
		if reply_to != "" {
			cl.aknowledge_message(reply_to)
		}
	}
}

fn (mut cl NATSClient) aknowledge_message(reply_to string) {
	//$JS.ACK.ORDERS.test.1.2.2
	data := "PUB ${reply_to} 0\r\n\r\n"
	cl.logger.info("Anknowledge: $data")
	cl.websocket.write(data.bytes(), .binary_frame) or {
		cl.logger.error("Failed to send message")
	}
}

fn (mut cl NATSClient) create_stream() {
	// stream_config := StreamConfig{
	// 	name: "a_new_stream"
	// 	subjects: ["ORDERS2.*"]
	// }
	// stream_config_json := json.encode(stream_config)
	// data := "PUB \$JS.API.STREAM.CREATE.a_new_stream ${stream_config_json.len}\r\n${stream_config_json}\r\n"

	// consumer_config := ConsumerConfig{
	// 	stream_name: "my_stream"
	// 	config: ConsumerInnerConfig {
	// 		durable_name: "my_consumer"
	// 		deliver_subject: "push"
	// 	}
	// }
	// consumer_config_json := json.encode(consumer_config)
	// data := "PUB \$JS.API.CONSUMER.CREATE.my_stream.my_consumer ${consumer_config_json.len}\r\n${consumer_config_json}\r\n"
	//data := "SUB ORDERS.* 1\r\n"

	cl.logger.info("Asking for next message")
	next_msg := ConsumerNextMSG {
		batch: 1
		expires: 0
		max_bytes: 5000000000
		no_wait: true
		idle_heartbeat: 5
	}
	next_msg_json := json.encode(next_msg)
	json_data := '{"batch":1,"no_wait":true}'
	data := "PUB \$JS.API.CONSUMER.MSG.NEXT.my_stream.my_consumer RESPONSE ${json_data.len}\r\n${json_data}\r\n"
	//json_d := '{}'
	//data := "PUB \$JS.API.STREAM.MSG.GET.my_stream RESPONSE ${json_d.len}\r\n${json_d}\r\n"
	cl.logger.info("$data")
	cl.websocket.write(data.bytes(), .binary_frame) or {
		cl.logger.error("Failed to send message")
	}
}

fn (mut cl NATSClient) subscribe_consumer_response() {
	data := "SUB RESPONSE 1\r\n"
	cl.websocket.write(data.bytes(), .binary_frame) or {
		cl.logger.error("Failed to send message")
	}
}

fn (mut cl NATSClient) send_ping() {
	cl.websocket.write("PING\r\n".bytes(), .binary_frame) or {
		cl.logger.error("Failed to send PING")
	}
}

fn (mut cl NATSClient) send_pong() {
	cl.websocket.write("PONG\r\n".bytes(), .binary_frame) or {
		cl.logger.error("Failed to send PONG")
	}
}

fn (mut cl NATSClient) send_connect() {
	message_data := CONNECT_MESSAGE{
		verbose: false
		pedantic: true
		tls_required: false
		name: "v_client"
		lang: "V"
		version: "2.9.11"
		protocol: 1
		echo: true
	}
	message_data_encoded := json.encode(message_data)
	data := "CONNECT ${message_data_encoded}\r\n"
	cl.websocket.write(data.bytes(), .binary_frame) or {
		cl.logger.error("Failed to send message")
	}
}
pub fn (mut cl NATSClient) listen() ! {
	t := spawn cl.websocket.listen()
	for {
		cl.create_stream()
		time.sleep(5 * time.second)
	}
	t.wait()!
}

pub fn new_natsclient(address string, logger &log.Logger) !NATSClient {
	mut natsclient := NATSClient {
		address: address
		logger: unsafe { logger }
	}
	mut websocket := websocket.new_client(address, websocket.ClientOpt{ }) or {
		return error("failed to create client for $address: $err")
	}
	websocket.on_message(natsclient.on_message)
	natsclient.websocket = websocket
	websocket.connect()!
	natsclient.send_connect()
	return natsclient
}