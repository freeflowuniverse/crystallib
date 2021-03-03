module msgbus

import crypto.md5
import libsodium
import strings
import despiegk.crystallib.digitaltwin




pub struct MessageLowLevel {
pub mut:
	id int
	// version, so the bus knows how to deal with the msg
	version int = 1
	// dot notation
	cmd string
	// expiration in epoch
	expiration int
	// the data = payload which will be send to the twin_dest(s)
	data []byte
	// schema as used for data, normally empty but can be used to identify the version of the input to the target processor.method
	schema string
	// who is the originator
	twin_source int
	// for who is this message meant, can be more than 1
	twin_dest int
	// is the target which will pick up the msg and do something with it
	//'twin' is the digital twin nodejs proxy & the default
	target string = 'twin'
	// where do you want the return message to come to
	// if not specified then its bu
	return_queue string
	// md5 of version+cmd+expiration+data+schema+twin_source+twin_dest+target+return_queue+epoch
	fingerprint []byte
	// signature as done by the source
	signature []byte
	// direction (i is in=return, o=out to send)
	direction string
	// creation date in epoch (int)
	epoch int
}

fn (mut msg MessageLowLevel) fingerprint() {
	mut builder := strings.Builder{}
	builder.write_string('$msg.id')
	builder.write_string('$msg.version')
	builder.write_string(msg.cmd)
	builder.write_string('$msg.expiration')
	builder.write(msg.data) or { panic(err) }
	builder.write_string('$msg.twin_source')
	builder.write_string('$msg.twin_dest')
	builder.write_string(msg.target)
	builder.write_string(msg.direction)
	builder.write_string(msg.return_queue)
	builder.write_string('$msg.epoch')
	msg.fingerprint = md5.sum(builder.buf)
}

fn (mut msg MessageLowLevel) sign(mut twin_factory digitaltwin.DigitalTwinFactory) {
	if msg.fingerprint == []byte{} {
		msg.fingerprint()
	}
}
