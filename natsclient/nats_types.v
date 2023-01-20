module natsclient

// Configuration of all possible publish messages can be found at:
// https://github.com/nats-io/jsm.go/tree/main/schemas/jetstream/api/v1

// configuration for sending a CONNECT message
pub struct ConnectConfig {
	verbose bool
	pedantic bool
	tls_required bool
	name string
	lang string
	version string
	protocol int
	echo bool
}

// configuration for creating a stream
pub struct StreamConfig {
	// A unique name for the Stream, empty for Stream Templates.
	name string
	// A short description of the purpose of this stream
	description string
	// A list of subjects to consume, supports wildcards. Must be empty when a mirror is configured. May be empty when sources are configured.
	subjects []string
	// How messages are retained in the Stream, once this is exceeded old messages are removed. Should be one of:
	// 	limits = (default)
    // 	interest = 
	// 	workqueue"
	//retention string
	// How many Consumers can be defined for a given Stream. -1 for unlimited. (default -1)
	//max_consumers i64
	// How many messages may be in a Stream, oldest messages will be removed if the Stream exceeds this size. -1 for unlimited. (default -1)
	//max_msgs i64
	// For wildcard streams ensure that for every unique subject this many messages are kept - a per subject retention limit (default -1)
	//max_msgs_per_subject i64
	// How big the Stream may be, when the combined stream size exceeds this old messages are removed. -1 for unlimited. (default -1)
	//max_bytes i64
	// Maximum age of any message in the stream, expressed in nanoseconds. 0 for unlimited. (default 0)
	//max_age i64
	// The largest message that will be accepted by the Stream. -1 for unlimited. (default -1)
	//max_msg_size int
	// The storage backend to use for the Stream. One of: "file" (default), "memory"
	//storage 
	// How many replicas to keep for each message, best to choose 1 (no security), 3 (secure and performant) or 5 (super secure, no performance) (default 1, max 5)
	//num_replicas int
	// Disables acknowledging messages that are received by the Stream. (default false)
	//no_ack bool
	// When the Stream is managed by a Stream Template this identifies the template that manages the Stream.
	//template_owner string
	// When a Stream reach it's limits either old messages are deleted or new ones are denied. One of: "old" (default), "new"
	//discard string
	// The time window to track duplicate messages for, expressed in nanoseconds. 0 for default
	//duplicate_window i64
	// Placement directives to consider when placing replicas of this stream, random placement when unset
	//placement struct {
	// 	// The desired cluster name to place the stream
	// 	cluster string
	// 	// The tags required on servers hosting this stream
	// 	tags []string
	//}
}

// configuration for creating a consumer
pub struct ConsumerConfig {
	stream_name string
	config struct {
		// TODO experiment with the configuration parameters below
		// A unique name for a consumer
		name string
		// A short description of the purpose of this consumer
		description string
		// Should be one of: 
		//   none: messages must not be acknowledged
		//   all: only acknowledge the last message of a series of messages, all others will be acknowledged too
		//   explicit: each message must be acknowledged
		ack_policy string
		// How long (in nanoseconds) to allow messages to remain un-acknowledged before attempting redelivery (default 30000000000)
		//ack_wait int
		// The number of times a message will be redelivered to consumers if not acknowledged in time // default -1
		//max_deliver int
		// Filter which messages you want to receive from the stream
		//filter_subject string
		// Should be one of:
		//   instant = receive all message as fast as possible (default)
		//   original = receive messages in the timing they were published
		//replay_policy string
		// The maximum number of messages without acknowledgement that can be outstanding, once this limit is reached message delivery will be suspended (default 1000)
		//max_ack_pending int 
		// The number of pulls that can be outstanding on a pull consumer, pulls received after this is reached are ignored (default 512)
		//max_waiting int
		// The largest batch property that may be specified when doing a pull on a Pull Consumer (default 0)
		//max_batch int
		// The maximum expires value that may be set when doing a pull on a Pull Consumer
		//max_expires int
		// The maximum bytes value that maybe set when dong a pull on a Pull Consumer (default 0)
		//max_bytes int
		// When set do not inherit the replica count from the stream but specifically set it to this amount
		//num_replicas int
		// Force the consumer state to be kept in memory rather than inherit the setting from the stream (default false)
		//mem_state bool 
	}
}

// configuration for pulling the next message(s) from a consumer
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