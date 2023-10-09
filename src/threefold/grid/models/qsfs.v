module models

pub struct QuantumSafeFS {
	cache  u64
	config QuantumSafeFSConfig
}

pub struct QuantumSafeFSConfig {
	minimal_shards        u32
	expected_shards       u32
	redundant_groups      u32
	redundant_nodes       u32
	max_zdb_data_dir_size u32
	encryption            Encryption
	meta                  QuantumSafeMeta
	goups                 []ZDBGroup
	compression           QuantumCompression
}

pub struct Encryption {
	algorithm string // format?
	key       []u8   // TODO: how to create challenge, document
}

pub struct QuantumSafeMeta {
	type_  string            [json: 'type']
	config QuantumSafeConfig
}

pub struct ZDBGroup {
	backends []ZDBBackend
}

pub struct ZDBBackend {
	address   string // format?
	namespace string
	password  string
}

pub struct QuantumCompression {
	algorithm string // format?
}

pub struct QuantumSafeConfig {
	prefix     string
	encryption Encryption
	backends   []ZDBBackend
}

pub fn (qsfs QuantumSafeFS) challenge() string {
	return ''
}
