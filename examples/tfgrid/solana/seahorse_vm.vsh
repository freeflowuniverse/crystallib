#!/usr/bin/env -S v -n -w -enable-globals run

import freeflowuniverse.crystallib.threefold.grid.models
import freeflowuniverse.crystallib.threefold.grid as tfgrid
import freeflowuniverse.crystallib.threefold.gridproxy
import time
import flag
import rand
import json
import log
import os
import io

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('Seahorse dev tool')
	fp.version('v0.0.1')
	fp.skip_executable()

	mnemonics := fp.string_opt('mnemonic', `m`, 'Your Mnemonic phrase')!
	chain_network := fp.string('network', `n`, 'main', 'Your desired chain network (main, test, qa, dev). Defaults to main')
	ssh_key := fp.string_opt('ssh_key', `s`, 'Your public ssh key')!
	code_server_pass := fp.string('code_server_pass', `p`, 'password', 'Machine code server password. This will be set as a password for the code server on the deployed machine. Defaults to password')
	cpu := fp.int('cpu', `c`, 4, 'Machine CPU provisioning. Defaults to 4')
	memory := fp.int('ram', `r`, 8, 'Machine memory provisioning in GB. Defaults to 8')
	disk := fp.int('disk', `d`, 30, 'Machine Disk space provisioning in GB. Defaults to 30')
	public_ip := fp.bool('public_ip', `i`, false, 'True to allow public ip v4')

	mut logger := &log.Log{}
	logger.set_level(.debug)

	// ##### Part 1 #####


	nodes=tfgrid.search(...)! //gives error if no nodes

	//default is mycelium
	vm:=tfgrid.vm_new(profilename="main",name="myvm",mem_mb=4000,ssd_gb=50,cpu_cores=4,nodeid=nodes[0].id,flist='')

	vm.shell()
	vm.ipaddr

	vm.webgw_add(...)

	b:=vm.builder()!

	vm:=tfgrid.vm_get(...)
	vm.delete()!

	//gives me a builder (can do ssh on it)
	b.exec(..)

	chain_net_enum := get_chain_network(chain_network)!
	mut deployer := tfgrid.new_deployer(mnemonics, chain_net_enum, mut logger)!
	
	mut workloads := []models.Workload{}
	// node_id := get_node_id(chain_net_enum, memory, disk, cpu, public_ip)!
	node_id := u32(146)
	logger.info('deploying on node: ${node_id}')




	network_name := 'net_${rand.string(5).to_lower()}' // autocreate a network
	wg_port := deployer.assign_wg_port(node_id)!
	mut network := models.Znet{
		ip_range: '10.1.0.0/16' // auto-assign
		subnet: '10.1.1.0/24' // auto-assign
		wireguard_private_key: 'GDU+cjKrHNJS9fodzjFDzNFl5su3kJXTZ3ipPgUjOUE=' // autocreate
		wireguard_listen_port: wg_port
		mycelium: models.Mycelium{
			hex_key: rand.string(32).bytes().hex()
		}

	}
	
	workloads << network.to_workload(name: network_name, description: 'test_network1')

	mut public_ip_name := ''
	if public_ip{
		public_ip_name = rand.string(5).to_lower()
		workloads << models.PublicIP{
			v4: true
		}.to_workload(name: public_ip_name)
	}

	zmachine := models.Zmachine{
		flist: 'https://hub.grid.tf/petep.3bot/threefolddev-ubuntu24.04-latest.flist'
		network: models.ZmachineNetwork{
			interfaces: [
				models.ZNetworkInterface{
					network: network_name
					ip: '10.1.1.3'
				},
			]
			public_ip: public_ip_name
			planetary: true
			mycelium: models.MyceliumIP{
				network: network_name
				hex_seed: rand.string(6).bytes().hex()
			}
		}
		entrypoint: '/sbin/zinit init' // from user or default
		compute_capacity: models.ComputeCapacity{
			cpu: u8(cpu)
			memory: i64(memory) * 1024 * 1024 * 1024
		}
		size: u64(disk) * 1024 * 1024 * 1024
		env: {
			'SSH_KEY':              ssh_key
			'CODE_SERVER_PASSWORD': code_server_pass
		}
	}

	workloads << zmachine.to_workload(
		name: 'vm_${rand.string(5).to_lower()}'
		description: 'zmachine_test'
	)

	signature_requirement := models.SignatureRequirement{
		weight_required: 1
		requests: [
			models.SignatureRequest{
				twin_id: deployer.twin_id
				weight: 1
			},
		]
	}

	mut deployment := models.new_deployment(
		twin_id: deployer.twin_id
		description: 'seahorse deployment'
		workloads: workloads
		signature_requirement: signature_requirement
	)
	deployment.add_metadata('vm', 'SeahorseVM')

	contract_id := deployer.deploy(node_id, mut deployment, deployment.metadata, 0) or {
		logger.error('failed to deploy deployment: ${err}')
		exit(1)
	}
	logger.info('deployment contract id: ${contract_id}')
	dl := deployer.get_deployment(contract_id, node_id) or {
		logger.error('failed to get deployment data: ${err}')
		exit(1)
	}

	// logger.info('deployment:\n${dl}')
	machine_res := get_machine_result(dl)!
	logger.info('zmachine result: ${machine_res}')


	// Add a small delay after deployment to ensure the VM is fully up and running before attempting to connect
	// time.sleep(30 * time.second) // Wait for 30 seconds

	// ##### Part 2 #####

	// Check if mycelium is installed on my local machine
    if !is_mycelium_installed() {
        logger.error('Mycelium is not installed. Please install Mycelium before proceeding.')
        return
    } else {
		logger.info('Mycelium is installed.')
	}

	// Check if mycelium is running on my local machine
    if !is_mycelium_running() {
        // logger.info('Warning: Mycelium is not running.')
		// logger.info('Attempting to start Mycelium...')
        // os.execute('sudo mycelium --peers tcp://188.40.132.242:9651 tcp://[2a01:4f8:212:fa6::2]:9651 quic://185.69.166.7:9651 tcp://[2a02:1802:5e:0:8c9e:7dff:fec9:f0d2]:9651 tcp://65.21.231.58:9651 quic://[2a01:4f9:5a:1042::2]:9651')
        // // Wait a bit and check again
        // time.sleep(5 * time.second)
        // if !is_mycelium_running() {
        //     logger.error('Failed to start Mycelium. Please start it manually before proceeding.')
        //     return
        // }

		logger.error('Mycelium is not running.')
		return
    } else {
		logger.info('Mycelium is running.')
	}

	remote_mycelium_ip := '405:e3fc:c4e:4004:ff0f:6a49:7a54:7850'
	logger.info('Mycelium IP: ${remote_mycelium_ip}')

	// Ping remote mycelium ip
	if !ping_ip(remote_mycelium_ip, 5) {
        logger.error('Failed to ping ${remote_mycelium_ip} after 5 attempts')
        return
    } else {
		logger.info('Successed to ping ${remote_mycelium_ip}')
	}

	// Attempt the SSH connection
	if !try_ssh_connection(remote_mycelium_ip) {
		logger.error('Unable to establish SSH connection. Please check your network and VM status.')
		return
    } else {
        logger.info('Ready to proceed with further operations')
    }

	// Run installation script on remote VM
	seahorse_install_script := 'seahorse_install.sh'
    if !execute_remote_script(remote_mycelium_ip, seahorse_install_script) {
        logger.error('Seahorse remote installation failed')
		return
    } else {
		logger.info('Seahorse remote installation completed successfully')
    }
}

// Function to check if Mycelium is installed
fn is_mycelium_installed() bool {
    result := os.execute('mycelium --version')
    return result.exit_code == 0
}

// Function to check if Mycelium is running locally
fn is_mycelium_running() bool {
    mut logger := &log.Log{}
    logger.set_level(.debug)

    // Use pgrep to find Mycelium processes
    result := os.execute('pgrep -f "^mycelium\\s"')
    
    if result.exit_code != 0 {
        logger.debug('No Mycelium process found')
        return false
    }
    
    pids := result.output.trim_space().split('\n')
    logger.info('Mycelium process IDs: ${pids}')

    return pids.len > 0
}

fn ping_ip(ip string, attempts int) bool {
    for i := 0; i < attempts; i++ {
        result := os.execute('ping6 -c 1 -W 2 $ip')
        if result.exit_code == 0 {
            return true
        }
        time.sleep(1 * time.second)
    }
    return false
}

fn try_ssh_connection(mycelium_ip string) bool {
	mut logger := &log.Log{}
	logger.set_level(.debug)

	logger.info('Attempting SSH connection...')
    
    // Use -6 flag to force IPv6
    command := 'ssh -6 -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@${mycelium_ip} true'

	logger.info('Executing SSH command: ${command}')
    result := os.execute(command)
    
    if result.exit_code == 0 {
        logger.info('SSH connection successful')
        return true
    } else {
        logger.info('SSH connection failed: ${result.output}')
        return false
    }
}

fn execute_remote_script(mycelium_ip string, script_name string) bool {
    mut logger := &log.Log{}
    logger.set_level(.info)

    // Get the directory of the V script
    v_script_dir := os.dir(os.executable())
    logger.info('V script directory: ${v_script_dir}')

    // Construct the full path to the install script
    script_path := os.join_path(v_script_dir, script_name)
    logger.info('Full script path: ${script_path}')

    // Ensure the script exists
    if !os.exists(script_path) {
        logger.error('Script ${script_path} not found')
        return false
    }

    // Format the IPv6 address correctly for SSH and SCP commands
	ssh_ip := mycelium_ip
    scp_ip := if mycelium_ip.contains(':') { '[${mycelium_ip}]' } else { mycelium_ip }

	remote_script_path := '/tmp/${script_name}'

    // Construct the SSH and SCP commands
    scp_command := 'scp -6 -o StrictHostKeyChecking=no ${script_path} root@${scp_ip}:${remote_script_path}'
    ssh_command := 'ssh -6 -o ConnectTimeout=10 -o StrictHostKeyChecking=no root@${ssh_ip}'

    // Copy the script to the remote machine
    logger.info('Copying script to remote machine: ${scp_command}')
    scp_result := os.execute(scp_command)
    if scp_result.exit_code != 0 {
        logger.error('Failed to copy script. Exit code: ${scp_result.exit_code}')
        logger.error('SCP output: ${scp_result.output}')
        return false
    }

    // Verify if the script was copied successfully
    check_file_command := '${ssh_command} "ls -l ${remote_script_path}"'
    check_result := os.execute(check_file_command)
    if check_result.exit_code != 0 {
        logger.error('Failed to verify script on remote machine. Exit code: ${check_result.exit_code}')
        return false
    }
    logger.info('Script found on remote machine: ${remote_script_path}')

    // Now execute the script on the remote machine and stream the output
    run_script_command := '${ssh_command} "bash ${remote_script_path}"'
    logger.info('Executing remote script: ${run_script_command}')
	run_result := os.execute(run_script_command)
    if run_result.exit_code == 0 {
        logger.info('Remote script execution completed successfully')
        return true
    } else {
        logger.error('Remote script execution failed with exit code: ${result.exit_code}')
        return false
    }
}