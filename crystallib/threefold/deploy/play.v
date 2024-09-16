module play


const example_hero_script = "

!!tfgriddeploy.define_requirement
    name: 'MyVMRequirements'
    description: 'Requirements for a test VM on the TF Grid'
    cpu: 4
    memory: 8
    public_ip4: true
    public_ip6: false
    planetary: true
    mycelium: false
    heroscript: '
		!!tfgriddeploy.define_network
			name: TestNetwork
			ip_range:
		'
    nodes: '1,2,3'

!!tfgriddeploy.define_requirement_network
	name: 'TestNetwork'
	ip_range: '192.168.0.0/24'
	subnet: '255.255.255.0'


"