
module tfgrid

[params]
//TODO: describe parameters, what is metadata?
pub struct MachinesModel {
pub:
	name        string    [required]
	network     Network   [required]
	machines    []Machine [required]
	metadata    string
	description string
}

// params
//   cpu: TODO what is the u32
//   TODO: lets fill the other things in, and what is meaning of the parameters
pub struct Machine {
pub:
	name        string     [required]
	node_id     u32        [required]
	disks       []Disk
	// qsfs_disks  []QsfsDisk  //for now not supported
	public_ip   bool
	planetary   bool
	cpu         u32 = 1 
	memory      u64 = 1
	rootfs_size u64 = 10
	flist       string = "" //TODO: fill basic flist in
	entrypoint  string = "/"
	ssh_key		string = "" //TODO: do we have other way how to get environment arguments inside VM
}

pub struct Disk {
pub:
	name       string [required]
	size       u32    [required]
	mountpoint string [required]
}


// [params]
// pub struct QsfsDisk {
// pub:
// 	qsfs_zdbs_name  string [required]
// 	name            string [required]
// 	prefix          string [required]
// 	encryption_key  string [required]
// 	cache           u32
// 	minimal_shards  u32
// 	expected_shards u32
// 	mountpoint      string [required]
// }


