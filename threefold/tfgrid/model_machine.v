module tfgrid

[params]
pub struct MachinesModel {
pub:
	name        string    [required]
	node_id     u32
	network     Network   [required]
	machines    []Machine [required]
	metadata    string
	description string
}

pub struct MachinesResult {
pub:
	network_result NetworkResult
	machine_result []MachineResult
}

pub struct Machine {
pub:
	name        string [json: 'name'; required]
	disks       []Disk [json: 'disks']
	public_ip   bool   [json: 'public_ip']
	planetary   bool   [json: 'planetary']
	cpu         u32    [json: 'cpu']         = 2 // the amount of virtual CPUs for this vm
	memory      u64    [json: 'memory']      = 4000 // memory in MBs
	rootfs_size u64    [json: 'rootfs_size'] = 1000 // root filesystem size in MBs
	flist       string [json: 'flist']      = 'https://hub.grid.tf/tf-official-apps/base:latest.flist'
	entrypoint  string [json: 'entrypoint'] = '/sbin/zinit init'
	ssh_key     string [json: 'ssh_key']
	// qsfs_disks  []QsfsDisk  //for now not supported
}

pub struct Disk {
pub:
	name       string [required]
	size       u32    [required] // disk size in GBs
	mountpoint string [required]
}

struct MachineResult {
pub:
	name       string
	public_ip  string
	public_ip6 string
	ygg_ip     string
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
