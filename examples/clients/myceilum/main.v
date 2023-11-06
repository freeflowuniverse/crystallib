module main

import encoding.base64
import freeflowuniverse.crystallib.clients.myceilum { get_msg_status, receive_msg, reply_msg, send_msg }

fn main() {
	payload := 'hello'
	pk := '7cc15e9d1bd48969e436970b0059470cd97797f040514c4922da1f0b98614742'

	// send message and return without wating for response this will return jsut the id
	println('*** sending message without wait for reply ***')
	msg := send_msg(pk, base64.encode_str(payload), false)!
	println('message sent id: ${msg.id}')

	// check msg status
	println('*** getting message status ***')
	msg_st := get_msg_status(msg.id)!
	println('message status is res ${msg_st.state}')

	// send message and wait for response
	println('*** sending message and wait for reply ***')
	msg2 := send_msg(pk, base64.encode_str(payload), true)!
	println('got a reply: ${base64.decode_str(msg2.payload)}')

	// receive msg
	println('*** receive message ***')
	msg3 := receive_msg(true)!
	println('received a new message: ${base64.decode_str(msg3.payload)}')

	// receive msg and reply
	println('*** receive message and reply to it ***')
	msg4 := receive_msg(true)!
	println('received another message to reply to: ${base64.decode_str(msg4.payload)}')
	res := reply_msg(msg4.id, pk, base64.encode_str('thnx'))!
	println(res)
}
