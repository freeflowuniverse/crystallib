module rmbprocessor



//--------------------------------
// WEBSOCKET MESSAGES
//--------------------------------
//MSG <subject> <sid> [reply-to] <#bytes>␍␊[payload]␍␊
pub fn parse_message(payload string) {

}

pub struct NATSMessage {
pub mut:
	subject string
	sid string
	reply_to string
	message string
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



//------------------------------
// REQUEST CONFIGURATIONS
//------------------------------
pub struct StreamConfig {
	name string
	subjects []string
}

pub struct ConsumerInnerConfig {
	// A unique name for a consumer
	name string
	
	// A short description of the purpose of this consumer
	description string
	
	// none: messages must not be acknowledged
	// all: only acknowledge the last message of a series of messages, all others will be acknowledged too
	// explicit: each message must be acknowledged
	ack_policy string
	
	// How long (in nanoseconds) to allow messages to remain un-acknowledged before attempting redelivery (default 30000000000)
	//ack_wait int
	
	// The number of times a message will be redelivered to consumers if not acknowledged in time // default -1
	// max_deliver int
	
	// Filter which messages you want to receive from the stream
	// filter_subject string

	// instant = receive all message as fast as possible (default)
	// original = receive messages in the timing they were published
	// replay_policy string

	// The maximum number of messages without acknowledgement that can be outstanding, once this limit is reached message delivery will be suspended (default 1000)
    // max_ack_pending int 
	
	// The number of pulls that can be outstanding on a pull consumer, pulls received after this is reached are ignored (default 512)
    // max_waiting int

	// The largest batch property that may be specified when doing a pull on a Pull Consumer (default 0)
	// max_batch int

	// The maximum expires value that may be set when doing a pull on a Pull Consumer
	// max_expires int

	// The maximum bytes value that maybe set when dong a pull on a Pull Consumer (default 0)
	// max_bytes int

	// When set do not inherit the replica count from the stream but specifically set it to this amount
	// num_replicas int

	// Force the consumer state to be kept in memory rather than inherit the setting from the stream (default false)
	// mem_state bool 
}

pub struct ConsumerConfig {
	stream_name string
	config ConsumerInnerConfig
}

pub struct ConsumerNextMSG {
	// A duration from now when the pull should expire, stated in nanoseconds, 0 for no expiry
	expires i64
	// How many messages the server should deliver to the requestor
	batch int
	// Sends at most this many bytes to the requestor, limited by consumer configuration max_bytes
    // max_bytes int
	// When true a response with a 404 status header will be returned when no messages are available (default false)
    no_wait bool
	// When not 0 idle heartbeats will be sent on this interval
	// idle_heartbeat int
}