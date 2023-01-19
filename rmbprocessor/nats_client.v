
module rmbprocessor

import freeflowuniverse.crystallib.rmbclient
import freeflowuniverse.crystallib.encoder

import json
import log
import net.http
import net.websocket
import rand
import time


[heap]
pub struct NATSClient {
pub mut:
	pull_frequency int = 5 // pull every 5 seconds
	address string
	websocket &websocket.Client
	logger &log.Logger
}

fn (mut cl NATSClient) on_message(mut client websocket.Client, msg &websocket.Message) ! {
	//INFO
	//MSG
	//PING
	//PONG
	//HMSG
	//+OK
	//-ERR
	
	message_string := msg.payload.bytestr()
	cl.logger.debug("New message: <$message_string>")
	i := 0
	match message_string[0] {
		73 { //"INFO"
			// TODO do something with INFO object
			cl.subscribe("RESPONSE") or {
				cl.logger.error("Failed to subscribe: $err")
			}
		}
		77 { // MSG
			cl.parse_msg(message_string) or {
				cl.logger.error("$err")
			}
		}
		80 { // PING or PONG
			if message_string == "PING\r\n" {
				cl.send_pong()
			}
		}
		43 { // +OK

		}
		45 { // -ERR

		}
		else {
			cl.logger.error("Message <$message_string> not supported!")
		}
	}
}

fn (mut cl NATSClient) parse_msg(payload string) ! {
	mut natsmsgparser := NATSMessageParser{}
	messages := natsmsgparser.parse(payload) or {
		return error("Parse MSG: failed to parse messages")
	}
	cl.logger.info("New batch of messages: ${messages.len}")
	cl.logger.debug("$messages")
	if messages.len == 1 && message[0].message == "" {
		// Server tells us there are no more messages to pull
		return 
	}
	// todo add channel or push message to redis
	cl.aknowledge_message(messages[messages.len-1].reply_to)
}

fn (mut cl NATSClient) aknowledge_message(reply_to string) {
	data := "PUB ${reply_to} 0\r\n\r\n"
	cl.logger.debug("Sending: $data")
	cl.websocket.write(data.bytes(), .binary_frame) or {
		cl.logger.error("Aknowledge message: Failed to send message")
	}
}

pub fn (mut cl NATSClient) create_stream(name string, subjects []string) ! {
	stream_config := json.encode(StreamConfig{
		name: name
		subjects: subjects
	})
	data := "PUB \$JS.API.STREAM.CREATE.${name} ${stream_config.len}\r\n${stream_config}\r\n"
	cl.logger.debug("Sending: $data")
	cl.websocket.write(data.bytes(), .binary_frame) or {
		return error("Create stream: failed to send message: $err")
	}
}

pub fn (mut cl NATSClient) create_consumer(name string, stream string, description string) ! {
	consumer_config := json.encode(ConsumerConfig {
		stream_name: stream
		config: ConsumerInnerConfig {
			name: name
			description: description
			// TODO experiment with all => this would only require us to acknowledge the last message of a batch of messages
			ack_policy: "explicit"
		}
	})
	data := "PUB \$JS.API.CONSUMER.CREATE.${stream}.${name} ${consumer_config.len}\r\n${consumer_config}\r\n"
	cl.logger.debug("Sending: $data")
	cl.websocket.write(data.bytes(), .binary_frame) or {
		return error("Create consumer: failed to send message: $err")
	}
}

fn (mut cl NATSClient) pull_messages(batch_size int, expires i64) {
 	next_msg := json.encode(ConsumerNextMSG {
		expires: expires * time.second
		batch: batch_size
		no_wait: false
	})
	data := "PUB \$JS.API.CONSUMER.MSG.NEXT.my_stream.my_consumer RESPONSE ${next_msg.len}\r\n${next_msg}\r\n"
	cl.logger.debug("Sending: $data")
	cl.websocket.write(data.bytes(), .binary_frame) or {
		cl.logger.error("Pull messages: Failed to send message")
	}
}

pub fn (mut cl NATSClient) subscribe(subject string) !string {
	sid := rand.uuid_v4()
	data := "SUB $subject $sid\r\n"
	cl.logger.debug("Sending: $data")
	cl.websocket.write(data.bytes(), .binary_frame) or {
		return error("Subscribe: Failed to send message")
	}
	return sid
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
	message_data := json.encode(CONNECT_MESSAGE{
		verbose: false
		pedantic: true
		tls_required: false
		name: "v_client"
		lang: "V"
		version: "2.9.11"
		protocol: 1
		echo: true
	})
	data := "CONNECT ${message_data}\r\n"
	cl.websocket.write(data.bytes(), .binary_frame) or {
		cl.logger.error("Failed to send message")
	}
}

pub fn (mut cl NATSClient) listen() ! {
	t := spawn cl.websocket.listen()
	for {
		cl.pull_messages(20, cl.pull_frequency)
		// keep connection alive
		cl.send_ping()
		time.sleep(cl.pull_frequency * time.second)
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