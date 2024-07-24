## Creating Deployments

### Creating Network

- first you need to import the grid driver

```
import freeflowuniverse.crystallib.threefold.grid
```

- gather required data (mnemonics, twin, ...)

```
  mnemonics := grid.get_mnemonics()!
  mut deployer := grid.new_deployer(mnemonics, .dev, mut logger)!
  twin_id := deployer.client.get_user_twin()!
```

- create znet object

```
mut network := models.Znet{
		ip_range: '10.1.0.0/16'
		subnet: '10.1.1.0/24'
		wireguard_private_key: 'GDU+cjKrHNJS9fodzjFDzNFl5su3kJXTZ3ipPgUjOUE='
		wireguard_listen_port: 3012
		peers: [
			models.Peer{
				subnet: '10.1.2.0/24'
				wireguard_public_key: '4KTvZS2KPWYfMr+GbiUUly0ANVg8jBC7xP9Bl79Z8zM='
				allowed_ips: ['10.1.2.0/24', '100.64.1.2/32']
			},
		]
	}
```

    - iprange: is the range that nodes will be assigned ips from
    - subnet: is the range that vms will be assigned ips from
    - wireguard priv/pub keys can be generated using wireguard tool

- create network workload

```

    mut znet_workload := models.Workload{
    	version: 0
    	name: 'networkaa'
    	type_: models.workload_types.network
    	data: json.encode_pretty(network)
    	description: 'test network2'
    }

```

### creating disks

- create disk object

```
disk_name := 'mydisk'
	zmount := models.Zmount{
		size: 2 * 1024 * 1024 * 1024
	}
```

- create the disk workload out of it

```
	zmount_workload := zmount.to_workload(name: disk_name)
```

### creating public ip workload

```
public_ip_name := 'mypubip'
	ip := models.PublicIP{
		v4: true
	}
ip_workload := ip.to_workload(name: public_ip_name)
```

### Creating zmachine workload

- create mount for the disk we created obove

```
    mount := models.Mount{
    	name: disk_name
    	mountpoint: '/disk1'
    }

```

- create the zmachine object with all required machine data

```
	zmachine := models.Zmachine{
		flist: 'https://hub.grid.tf/tf-official-apps/base:latest.flist'
		entrypoint: '/sbin/zinit init'
		network: models.ZmachineNetwork{
			public_ip: public_ip_name
			interfaces: [
				models.ZNetworkInterface{
					network: 'networkaa'
					ip: '10.1.1.3'
				},
			]
			planetary: true
		}
		compute_capacity: models.ComputeCapacity{
			cpu: 1
			memory: i64(1024) * 1024 * 1024 * 2
		}
		env: {
			'SSH_KEY': pubkey
		}
		mounts: [mount]
	}
```

- create the zmachine workload out of that object

```
	mut zmachine_workload := models.Workload{
		version: 0
		name: 'vm2'
		type_: models.workload_types.zmachine
		data: json.encode(zmachine)
		description: 'zmachine test'
	}
```

### creating zlogs

```
zlogs := models.ZLogs{
		zmachine: 'vm2'
		output: 'wss://example_ip.com:9000'
	}
	zlogs_workload := zlogs.to_workload(name: 'myzlogswl')
```

- zmachine: the machine that will use this zlogs
- output is where the logs will be sent

### creating zdbs

```
zdb := models.Zdb{
		size: 2 * 1024 * 1024
		mode: 'seq'
	}
	zdb_workload := zdb.to_workload(name: 'myzdb')
```

### creating the deployments with all the above workloads

- create deployment object

```
mut deployment := models.Deployment{
		version: 0
		twin_id: twin_id
		description: 'zm kjasdf1nafvbeaf1234t21'
		workloads: [znet_workload, zmount_workload, zmachine_workload, zlogs_workload, zdb_workload,
			ip_workload]
		signature_requirement: models.SignatureRequirement{
			weight_required: 1
			requests: [
				models.SignatureRequest{
					twin_id: twin_id
					weight: 1
				},
			]
		}
	}
```

- adding deployment metadata

```
deployment.add_metadata('myproject', 'hamada')
```

- deploy the deployment on the node and get the contract id

```
node_id := u32(14)
	solution_provider := u64(0)

	contract_id := deployer.deploy(node_id, mut deployment, deployment.metadata, solution_provider)!
```

### Get Deployments

- now to get the deployment you just created do the following

```
res_deployment := deployer.get_deployment(contract_id, node_id)!

	mut zmachine_planetary_ip := ''
	for wl in res_deployment.workloads {
		if wl.name == zmachine_workload.name {
			res := json.decode(models.ZmachineResult, wl.result.data)!
			zmachine_planetary_ip = res.planetary_ip
			break
		}
	}
```

### adding a gateway workload to the deployment and update it

#### create gateway workload and create it's contract

- create gateway workload

```
gw_name := models.GatewayNameProxy{
		name: 'mygwname1'
		backends: ['http://[${zmachine_planetary_ip}]:9000']
	}
	gw_name_wl := gw_name.to_workload(name: 'mygwname1')

```

- create gw contract

```
name_contract_id := deployer.client.create_name_contract('mygwname1')!
```

#### updating deployment

```
deployment.workloads << gw_name_wl
	deployer.update_deployment(node_id, mut deployment, deployment.metadata)!

```
