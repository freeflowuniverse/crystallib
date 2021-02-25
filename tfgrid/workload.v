module tfgrid

import time

struct Workload {
	id int
	// Version is version of reservation object
	version int
	// ID of the reservation
	user_id int // Identification of the user requesting the reservation
	// Type of the reservation (container, zdb, vm, etc...)
	workload_type WorkloadType
	// Data is the reservation type arguments.
	data string
	// Date of creation
	created time.Time
	// ToDelete is set if the user/farmer asked the reservation to be deleted
	to_delete bool
	// Metadata is custom user metadata
	metadata string
	// Description
	description string
	// Tag object is mainly used for debugging.
	tags Tags
	// User signature
	signature string
	// Result of reservation
	result string
}

enum ResultState{
	accepted
	error
	ok	
	deleted
}

struct Result{
	created time.Time
	state ResultState
	error string
	data string
	signature string
}

enum WorkloadType {
	// ContainerType type
	container
	// VolumeType type
	volume
	// NetworkType type
	network
	// ZDBType type
	zdb
	// KubernetesType type
	kubernetes
	// PublicIPType reservation
	ipv4
}

//signs the signature given the private key
fn (mut wl Workload) sign (user User) ?{

}

//verifies user signature
fn (mut wl  Workload) verify (user User) ?{

}

fn (mut wl  Workload) tag_append (tag Tag) ?{

}

