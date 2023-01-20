
module natsclient

import json
import log
import net.websocket
import rand
import time

type ConsumerList = []string

[heap]
pub struct NATSClient {
mut:
	myinbox string
	websocket &websocket.Client
	address string
	stream_to_consumers map[string]ConsumerList

pub mut:
	pull_frequency int = 5 // pull every 5 seconds
	logger &log.Logger
}

fn (mut cl NATSClient) on_message(mut client websocket.Client, msg &websocket.Message) ! {
	payload := msg.payload.bytestr()
	cl.logger.debug("New message: <$payload>")
	match payload[0] {
		73 { //"INFO"
			// TODO do something with INFO object
			// we subscribe to our inbox (all messages from consumers will go there)
			cl.subscribe(cl.myinbox) or {
				cl.logger.error("Failed to subscribe to our inbox")
			}
		}
		77 { // MSG 
			cl.parse_messages(payload) or {
				cl.logger.error("Failed to $err")
			}
		}
		80 { // PING or PONG
			if payload == "PING\r\n" {
				cl.send_pong()
			}
		}
		43 { // +OK

		}
		45 { // -ERR

		}
		else {
			cl.logger.error("Message <$payload> not supported!")
		}
	}
}

fn (mut cl NATSClient) parse_messages(payload string) ! {
	mut natsmsgparser := NATSMessageParser{}
	messages := natsmsgparser.parse(payload) or {
		return error("Parse MSG: failed to parse messages")
	}

	if messages.len == 1 && messages[0].message == "" {
		// TODO maybe the parser should ignore suche messages
		// Server tells us there are no more messages to pull
		return 
	}
	cl.logger.info("New batch of messages: ${messages.len}")
	cl.logger.debug("$messages")
	// TODO add channel or push message to redis and remove code below
	// we should let the user of this class acknowledge when he processed the message
	for message in messages {
		if message.reply_to != "" {
			cl.aknowledge_message(message.reply_to)
		}
	}
}

fn (mut cl NATSClient) aknowledge_message(reply_to string) {
	// TODO should we use reply_to to see if the ack was well received
	cl.publish(reply_to, "", "") or {
		cl.logger.error("Aknowledge message: Failed to send message")
	}
}

pub fn (mut cl NATSClient) create_stream(name string, subjects []string) ! {
	cl.logger.info("Creating stream with name ${name}")
	stream_config := json.encode(StreamConfig{
		name: name
		subjects: subjects
	})
	// TODO should we use reply_to to see if stream was correctly created
	cl.publish("\$JS.API.STREAM.CREATE.${name}", "", stream_config) or {
		return error("Create stream: failed to send message")
	}
	cl.stream_to_consumers[name] = []string{}
}

pub fn (mut cl NATSClient) create_consumer(name string, stream string, description string) ! {
	if !(stream in cl.stream_to_consumers){
		return error("Can't create consumer on stream $stream: stream doesn't exist!")
	}
	cl.logger.info("Creating consumer for stream ${stream} with name ${name}")
	consumer_config := json.encode(ConsumerConfig {
		stream_name: stream
		config: struct {
			name: name
			description: description
			// TODO experiment with all => this would only require us to acknowledge the last message of a batch of messages
			ack_policy: "explicit"
		}
	})
	// TODO should be we use reply_to to know if the consumer was created?
	cl.publish("\$JS.API.CONSUMER.CREATE.${stream}.${name}", "", consumer_config)!
	cl.stream_to_consumers[stream] << name
}

fn (mut cl NATSClient) pull_messages(batch_size int, expires i64) {
	cl.logger.info("Sending pull request with batch size ${batch_size}")
	for stream, consumers in cl.stream_to_consumers {
		for consumer in consumers {
			next_msg := json.encode(ConsumerNextMSG {
				expires: expires * time.second
				batch: batch_size
				no_wait: false
			})
			cl.publish("\$JS.API.CONSUMER.MSG.NEXT.${stream}.${consumer}", cl.myinbox, next_msg) or {
				cl.logger.error("Failed to pull messages")
			}
		}
	}
}

pub fn (mut cl NATSClient) subscribe(subject string) !string {
	cl.logger.info("Subscribing to subject ${subject}")
	sid := rand.uuid_v4()
	data := "SUB $subject $sid\r\n"
	cl.logger.debug("Sending: $data")
	cl.websocket.write(data.bytes(), .binary_frame) or {
		return error("Subscribe: Failed to send message")
	}
	return sid
}

pub fn (mut cl NATSClient) publish(subject string, reply_to string, message string) ! {
	//TODO if reply_to != "" subscribe to that subject
	data := if reply_to == "" {
		"PUB ${subject} ${message.len}\r\n${message}\r\n"
	} else {
		"PUB ${subject} ${reply_to} ${message.len}\r\n${message}\r\n"
	}
	cl.logger.debug("Sending: $data")
	cl.websocket.write(data.bytes(), .binary_frame) or {
		return error("Publish: Failed to send message")
	}
}

fn (mut cl NATSClient) send_ping() {
	cl.logger.debug("PING >")
	cl.websocket.write("PING\r\n".bytes(), .binary_frame) or {
		cl.logger.error("Failed to send PING")
	}
}

fn (mut cl NATSClient) send_pong() {
	cl.logger.debug("PONG >")
	cl.websocket.write("PONG\r\n".bytes(), .binary_frame) or {
		cl.logger.error("Failed to send PONG")
	}
}

fn (mut cl NATSClient) send_connect() {
	cl.logger.info("Connecting with NATSServer")
	message_data := json.encode(ConnectConfig {
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
	cl.logger.debug("Sending data: ${data}")
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
	mut websocket := websocket.new_client(address, websocket.ClientOpt{ }) or {
		return error("failed to create client for $address: $err")
	}
	mut natsclient := NATSClient {
		address: address
		logger: unsafe { logger }
		websocket: websocket
	}
	websocket.on_message(natsclient.on_message)
	websocket.connect()!
	natsclient.send_connect()
	// myinbox is used to get messages back for consumers (should be unique)
	natsclient.myinbox = "myinbox" + rand.uuid_v4()
	return natsclient
}