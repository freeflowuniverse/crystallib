module stats

fn get_perf() {
	mut capacity:= Capacity{
		memory_gb: get_memory_gb()
		cpu: CPU{
			cpu_type, description, cpu_vcores: get_cpu_info()
		}
		disks: get_disk_info()
	}
	pub_key: 'dummy_public_key'
	mycelium_address: 'dummy_mycelium_address'
	pub_key_signature: 'dummy_signature'
    println(json.encode(registration))
}