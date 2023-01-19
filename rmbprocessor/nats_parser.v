module rmbprocessor

pub struct NATSMessageParser {
mut:
	data string
	i int
	subject string
	sid string
	reply_to string
	message_length int
	message string
}

pub fn (mut n NATSMessageParser) parse(data string) ![]NATSMessage {
	n.data = data
	mut c := 0
	mut messages := []NATSMessage {}
	for n.i < data.len {
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

		messages << NATSMessage {
			subject: n.subject
			sid: n.sid
			reply_to: n.reply_to
			message: n.message
		}
	}

	return messages
}

fn (mut n NATSMessageParser) should_find_msg() ! {
	if n.data[n.i .. n.i+4] != "MSG " {
		return error("invalid")
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
		if n.data[j..j+2] == "\r\n" && location_new_line == 0 { 
			location_new_line = j
			break
		}
		if n.data[j] == 32 {
			location_space = j
		}
		j += 1
	}
	if j+1 >= n.data.len {
		return error("invalid")
	}
	if location_space != 0 && location_space < location_new_line {
		// there is a reply_to specified
		n.reply_to = n.data[n.i..location_space]
		n.i = location_space + 1
	} else {
		// no reply_to specified and we know the message length now
		n.message_length = n.data[n.i..location_new_line].int()
		n.i = location_new_line+3
	}
}

fn (mut n NATSMessageParser) parse_message() ! {
	if n.message_length == -1 {
		j := n.find_next_new_line()!
		n.message_length = n.data[n.i .. j].int()
		n.i = j + 2
	}
	
	if n.i + n.message_length > n.data.len {
		return error("invalid")
	}
	n.message = n.data[n.i .. n.i+n.message_length]
	n.i = n.i + n.message_length
	if n.i+1 < n.data.len && n.data[n.i .. n.i+2] != "\r\n" {
		return error("invalid")
	}
	n.i += 2
}

fn (mut n NATSMessageParser) find_next_space() !int {
	mut j := n.i
	for j < n.data.len && n.data[j] != 32 {
		j += 1
	}
	if n.data[j] != 32 {
		return error("invalid")
	}
	return j
}

fn (mut n NATSMessageParser) find_next_new_line() !int {
	mut j := n.i
	for j+1 < n.data.len && n.data[j..j+2] != "\r\n" {
		j += 1
	}
	if n.data[j..j+2] != "\r\n" {
		return error("invalid")
	}
	return j
}