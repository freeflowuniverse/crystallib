module msgbus

import despiegk.crystallib.digitaltwin

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
	data []byte
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
}
