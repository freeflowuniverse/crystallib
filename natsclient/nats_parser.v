module natsclient

const (
	msg_ping = "PING\r\n"
	msg_pong = "PONG\r\n"
)

pub struct NATSMessage {
pub mut:
	subject string
	sid string
	reply_to string
	message string
}

pub struct NATSMessageParser {
mut:
	data string
	i int
	subject string
	sid string
	reply_to string
	message_length int
	message string

pub mut: 
	on_nats_message fn (message NATSMessage) =  fn (message NATSMessage) { }
	on_nats_info fn (data string) = fn (data string) {}
	on_nats_ping fn () = fn () { }
	on_nats_pong fn () = fn () { }
	on_nats_error fn (error string) = fn (error string) {}
}

pub fn (mut n NATSMessageParser) parse(data string) ! {
	n.data = data
	n.i = 0
	for n.i < n.data.len {
		match n.data[n.i] {
			73 { //"INFO"
				// TODO parse to actual info object
				info := n.parse_info()!
				n.on_nats_info(info)
			}
			77 { // MSG
				message := n.parse_msg()!
				n.on_nats_message(message)
			}
			80 { // PING or PONG
				if n.data[n.i .. ].starts_with(msg_ping) {
					n.i += msg_ping.len
					n.on_nats_ping()
				} else if n.data[n.i .. ].starts_with(msg_pong) {
					n.i += msg_pong.len
					n.on_nats_pong()
				}
			}
			43 { // +OK
			}
			45 { // -ERR
				// TODO parse to actual error object
				err := n.parse_err()!
				n.on_nats_error(err)
			}
			else {
				return error("Message <$data> not supported!")
			}
		}
	}
}

// ------------------------------------------------------------- 
pub fn (mut n NATSMessageParser) parse_err() !string {
	n.should_find_error()!
	j := n.find_next_new_line()!
	
	data := n.data[n.i .. j]

	n.i = j + 2
	return data
}

fn (mut n NATSMessageParser) should_find_error() ! {
	if n.i+5 >= n.data.len || n.data[n.i .. n.i+5] != "-ERR " {
		return error("invalid: should_find_error: not starting with -ERR")
	}
	n.i = n.i + 5
}

// -------------------------------------------------------------
pub fn (mut n NATSMessageParser) parse_info() !string {
	n.should_find_info()!
	j := n.find_next_new_line()!
	
	data := n.data[n.i .. j]

	n.i = j+2
	return data
}

fn (mut n NATSMessageParser) should_find_info() ! {
	if n.i+5 >= n.data.len || n.data[n.i .. n.i+5] != "INFO " {
		return error("invalid: should_find_info: not starting with INFO")
	}
	n.i = n.i + 5
}

// -------------------------------------------------------------
pub fn (mut n NATSMessageParser) parse_msg() !NATSMessage {
	n.subject = ""
	n.sid = ""
	n.reply_to = ""
	n.message_length = -1
	n.message = ""

	n.should_find_msg()!
	n.parse_subject()!
	n.parse_sid()!
	n.try_parse_reply_to()!
	n.parse_message()!

	return NATSMessage {
			subject: n.subject
			sid: n.sid
			reply_to: n.reply_to
			message: n.message
	}
}

fn (mut n NATSMessageParser) should_find_msg() ! {
	if n.i+4 >= n.data.len || n.data[n.i .. n.i+4] != "MSG " {
		return error("invalid: should_find_msg: not starting with MSG")
	}
	n.i = n.i + 4
}

fn (mut n NATSMessageParser) parse_subject() ! {
	j := n.find_next_space()!
	n.subject = n.data[n.i .. j]
	n.i = j+1
}

fn (mut n NATSMessageParser) parse_sid() ! {
	j := n.find_next_space()!
	n.sid = n.data[n.i .. j]
	n.i = j+1
}

fn (mut n NATSMessageParser) try_parse_reply_to() ! {
	mut location_new_line := 0
	mut location_space := 0
	mut j := n.i
	for j+1 < n.data.len {
		if n.data[j .. j+2] == "\r\n" && location_new_line == 0 { 
			location_new_line = j
			break
		}
		if n.data[j] == 32 {
			location_space = j
		}
		j += 1
	}
	if j+1 >= n.data.len {
		return error("invalid: try_parse_reply_to: no more data")
	}
	if location_space != 0 && location_space < location_new_line {
		// there is a reply_to specified
		n.reply_to = n.data[n.i .. location_space]
		n.i = location_space + 1
	} else {
		// no reply_to specified and we know the message length now
		n.message_length = n.data[n.i .. location_new_line].int()
		n.i = location_new_line + 2
	}
}

fn (mut n NATSMessageParser) parse_message() ! {
	if n.message_length == -1 {
		j := n.find_next_new_line()!
		n.message_length = n.data[n.i .. j].int()
		n.i = j + 2
	}

	if n.i + n.message_length > n.data.len {
		return error("invalid: parse_message: no more data")
	}
	if n.message_length > 0 {
		n.message = n.data[n.i .. n.i+n.message_length]
		n.i += n.message_length
	}
	if n.i+1 >= n.data.len || n.data[n.i .. n.i+2] != "\r\n" {
		return error("invalid: parse_message: no new line")
	}
	n.i += 2
}

// -------------------------------------------------------------

fn (mut n NATSMessageParser) find_next_space() !int {
	mut j := n.i
	for j < n.data.len && n.data[j] != 32 {
		j += 1
	}
	if n.data[j] != 32 {
		return error("invalid: find_next_space: no space found")
	}
	return j
}

fn (mut n NATSMessageParser) find_next_new_line() !int {
	mut j := n.i
	for j+1 < n.data.len && n.data[j .. j+2] != "\r\n" {
		j += 1
	}
	if j+1 >= n.data.len || n.data[j .. j+2] != "\r\n" {
		return error("invalid: find_next_new_line: no new line found")
	}
	return j
}