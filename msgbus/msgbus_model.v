module msgbus

import crypto.md5
import despiegk.crystallib.digitaltwin
import despiegk.crystallib.resp2

pub struct Expiration {
pub mut:
	// expiration in epoch
	expiration int
}

fn (mut exp Expiration) epoch() int {
	return exp.expiration
}

pub struct Message {
pub mut:
	// dot notation
	cmd string
	// expiration in epoch
	expiration Expiration
	// the data = payload which will be send to the twin_dest(s)
	data        []byte
	twin_source digitaltwin.DigitalTwinME
	// for who is this message meant, can be more than 1
	twin_dest []digitaltwin.DigitalTwin
	// is the target which will pick up the msg and do something with it
	//'twin' is the digital twin nodejs proxy & the default
	target string = 'twin'
	// where do you want the return message to come to
	// if not specified then its bu
	return_queue string
	// schema as used for data, normally empty but can be used to identify the version of the input to the target processor.method
	schema string
	// creation date in epoch (int)
	epoch int
	// direction 
	direction Direction
}

enum Direction {
	// will be encoded as 0,
	send
	// 1 is receive
	receive
}

// [version,data,hash,signature]
fn (mut m Message) encode() resp2.RValue {
	mut a := resp2.RArray{}

	mut data := resp2.RArray{}
	data.values << resp2.r_string(m.cmd)
	data.values << resp2.r_int(m.expiration.expiration)
	data.values << resp2.r_bytestring(m.data)
	data.values << resp2.r_int(m.twin_source.id)
	data.values << resp2.r_list_int(m.twin_dest.map(it.id))
	data.values << resp2.r_string(m.target)
	data.values << resp2.r_string(m.return_queue)
	data.values << resp2.r_string(m.schema)
	data.values << resp2.r_int(m.epoch)
	if m.direction == Direction.send {
		data.values << resp2.r_int(0)
	} else {
		data.values << resp2.r_int(1)
	}

	data_encoded := resp2.RValue(data).encode()

	a.values << resp2.r_int(1)
	a.values << resp2.r_bytestring(data_encoded)
	a.values << resp2.r_bytestring(md5.sum(data_encoded))
	a.values << resp2.r_nil() // will be filled in by bus, or we will do it here, can be decided

	return resp2.RValue(a)
}

fn decode(data []byte) ?Message {
	mut r0 := resp2.new_line_reader(data)

	version := r0.get_int() ?
	assert version == 1

	payload := r0.get_bytes() ?
	fingerprint := r0.get_bytes() ?
	signature := r0.get_bytes() ?

	// TODO: verify the fingerprint & the signature

	mut r := resp2.new_line_reader(payload)

	mut m := Message{}
	m.cmd = r.get_string() ?
	expiration := r.get_int() ?
	m.expiration = Expiration{
		expiration: expiration
	}
	m.data = r.get_bytes() ?

	twin_source_id := r.get_int() ?
	twin_dest_ids := r.get_list_int() ?

	// TODO: need to get the twin's from the factory and put in message

	m.target = r.get_string() ?
	m.return_queue = r.get_string() ?
	m.schema = r.get_string() ?
	m.epoch = r.get_int() ?
	direction := r.get_int() ?
	if direction == 0 {
		m.direction = Direction.send
	} else {
		m.direction = Direction.receive
	}

	return m
}
