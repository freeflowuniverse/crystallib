# Holochain Example

Mass deploys Holochain nodes with:
- codeserver
- dagu & server
- ssh
- mycelium
- yggdrasil

## How to use

The tfrobot requires Threefold Grid mneumonics so export them before running the example.
Depending on which network tfrobot is configured to, use corresponding. (default is main)

```bash
export TFGRID_MNEMONIC="jelly fork  ..."
```

Run the `holochain_deployer.vsh` script. This will deploy VMs. You can interact with the vms over:
- ssh
- codeserver at port 8080
- dagu api & ui at port 8081

go to ipaddress on port 8080 for seeing the codeserver.
e.g. http://[300:463c:9082:e2d6:413d:46e0:c6b1:3de2]:8080/

### Credentials

The credentials for the codeserver and dagu server can be set using the following environment variables. The default values for each variable is set below. 

```bash
CODE_SERVER_PASSWORD=password # password for code server
DAGU_BASICAUTH_USERNAME=admin # dagu ui and api username
DAGU_BASICAUTH_PASSWORD=password # dagu ui and api password
```

These environment variables can be passed to the vms using the following configuration when calling `tfrobot.deploy()`

```js
tfrobot.DeployConfig{
	vms: [
		tfrobot.VMConfig{
			env_vars: {
				'CODE_SERVER_PASSWORD': 'mypass'
			}
        }
    ]
}
```

# Phase 2

- each vm will start sshserver and a call backhome
- call back home is message over mycelium to the originator
    - download/install hero as part of the init or hero in flist
    - 'hero callhome $comma_separate_ipv6_list_mycelium'
    - the hero call home will keep on trying untill it got confirmation that it was received (for 24 h) 
    - in other words sends alive message to the TFRobot node who deployed the VM
    - TFRobot node runs vscript to do deploy, this vscript in loop keeps on showing progress of deploy as well as polling over mycelium if the alive message arrived
- installed mycelium
  

### ideas for later

- integrate with https://dagu.readthedocs.io/en/latest/web_interface.html