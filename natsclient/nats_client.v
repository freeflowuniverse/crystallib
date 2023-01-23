
module natsclient

import json
import log
import net.websocket
import rand
import time

const (
	natsclient_version_major = u8(0)
	natsclient_version_minor = u8(0)
	natsclient_version_patch = u8(1)
)

pub const natsclient_version = "${natsclient_version_major}.${natsclient_version_minor}.${natsclient_version_patch}"

type ConsumerList = []string

[heap]
pub struct NATSClient {
mut:
	uid string
	myinbox string
	websocket &websocket.Client
	address string
	stream_to_consumers map[string]ConsumerList
	ch_messages chan NATSMessage
	natsmsgparser &NATSMessageParser

pub mut:
	// pull every 5 seconds
	pull_frequency int = 5
	logger &log.Logger
}

fn (mut cl NATSClient) on_message(mut client websocket.Client, msg &websocket.Message) ! {
	payload := msg.payload.bytestr()
	cl.logger.debug("New message: \"${payload.trim_space()}\"")
	cl.natsmsgparser.parse(payload) or {
		cl.logger.error("Error parsing payload \"${payload}\": $err")
	}
}

pub fn (mut cl NATSClient) ack_message(ack_subject string) {
	// setting reply_to results in receiving a message once the ACK has been received by the server
	// though the received message is empty and has the same sid for all messages in that batch...
	cl.publish(ack_subject, "", "") or {
		cl.logger.error("Acknowledge message: Failed to send message")
	}
}

pub fn (mut cl NATSClient) create_stream(name string, subjects []string) ! {
	if name == "" {
		return error("Please provide a non empty name for the stream")
	}
	cl.logger.info("Creating stream with name ${name}")
	stream_config := json.encode(StreamConfig{
		name: name
		subjects: subjects
	})
	// TODO we receive that message in our inbox: we should parse it and if its an error
	// handle it
	cl.publish("\$JS.API.STREAM.CREATE.${name}", cl.myinbox, stream_config) or {
		return error("Create stream: failed to send message")
	}
	cl.stream_to_consumers[name] = []string{}
}

pub fn (mut cl NATSClient) create_consumer(name string, stream string, description string) ! {
	if name == "" {
		return error("Please provide a non empty name for the consumer")
	}
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
	cl.publish("\$JS.API.CONSUMER.CREATE.${stream}.${name}", cl.myinbox, consumer_config)!
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
			// Passing the reply_to results in getting a response message from the server. This can be an 
			// error or the configuration that the server used (with all default params too). We should 
			// handle the error and or parse the object
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
	cl.logger.debug("Sending: ${data.trim_space()}")
	cl.websocket.write(data.bytes(), .binary_frame) or {
		return error("Subscribe: Failed to send message")
	}
	return sid
}

pub fn (mut cl NATSClient) publish(subject string, reply_to string, message string) ! {
	// TODO if reply_to != "" subscribe to that subject and handel messages that we
	// get from it
	data := if reply_to == "" {
		"PUB ${subject} ${message.len}\r\n${message}\r\n"
	} else {
		"PUB ${subject} ${reply_to} ${message.len}\r\n${message}\r\n"
	}
	cl.logger.debug("Sending: ${data.trim_space()}")
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
		name: "v_client_${cl.uid}"
		lang: "V"
		version: natsclient_version
		protocol: 1
		echo: true
	})
	data := "CONNECT ${message_data}\r\n"
	cl.logger.debug("Sending data: ${data}")
	cl.websocket.write(data.bytes(), .binary_frame) or {
		cl.logger.error("Failed to send message")
	}
}

fn (mut cl NATSClient) nats_message(message NATSMessage) {
	if message.message == "" {
		// Empty messages can mean no more messages to process or an empty response from an 
		// executed request => we should maybe handle it more properly
		return
	}

	cl.logger.info("New message for subject ${message.subject}")
	cl.logger.debug("$message")

	if !cl.ch_messages.closed {
		if message.subject != cl.myinbox {
			cl.ch_messages <- message
		} else {
			cl.logger.info("$message.message")
		}
	}
}

fn (mut cl NATSClient) nats_info(data string) {
	cl.logger.info(data)
}

fn (mut cl NATSClient) nats_error(data string) {
	cl.logger.error(data)
}

pub fn (mut cl NATSClient) listen() ! {
	t := spawn cl.websocket.listen()
	for cl.websocket.state == .open {
		cl.pull_messages(20, cl.pull_frequency)
		// keep connection alive
		cl.send_ping()
		time.sleep(cl.pull_frequency * time.second)
	}
	t.wait()!
}

pub fn new_natsclient(address string, ch_messages chan NATSMessage, logger &log.Logger) !NATSClient {
	mut websocket := websocket.new_client(address, websocket.ClientOpt{ }) or {
		return error("failed to create client for $address: $err")
	}
	mut natsmsgparser := NATSMessageParser{}
	uid := rand.uuid_v4()
	mut natsclient := NATSClient {
		uid: uid
		myinbox: "myinbox" + uid
		address: address
		logger: unsafe { logger }
		websocket: websocket
		ch_messages: ch_messages
		natsmsgparser: &natsmsgparser
	}
	natsmsgparser.on_nats_message = natsclient.nats_message
	natsmsgparser.on_nats_info = natsclient.nats_info
	natsmsgparser.on_nats_ping = natsclient.send_pong
	natsmsgparser.on_nats_error = natsclient.nats_error

	websocket.on_message(natsclient.on_message)
	websocket.connect()!

	// myinbox is used to get messages back for consumers (should be unique)
	natsclient.send_connect()
	natsclient.subscribe(natsclient.myinbox) or {
		natsclient.logger.error("Failed to subscribe to our inbox")
	}

	return natsclient
}