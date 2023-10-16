# VM Example

The vm example exposes the following functionality:

- deploying a network of vms instance with custom specs.
- adding new vmds to a pre-existing network. this is done through the deploy operation, the network will be detected and updated.
- removing a vm from a pre-existing network.
- reading a vm instance from the grid.
- deleting a vm instance from the grid.

## CLI Arguments

The [vm cli](../../../../examples/tfgrid/vm.v) has the following arguments:

- mnemonic: user mnemonic.
- network: chain network to use. defaults to `dev`
- address: address of web3proxy to connect to. defaults to `ws://127.0.0.1:8080`.
- operation: this is the operation that you want to perform. must be one of `deploy`, `get`, or `delete`.
- debug: true to print debug logs.

### Deploy Operation Arguments

- vm_name: vm name
- vm_network: identifier for the vm network
- farm_id: farm id to deploy on. defaults to `0`
- capacity: capcacity of the vms. must be one of `small`, `medium`, `large`, or `extra-large`. defaults to `medium`.
- times: the number of vms to deploy. defaults to `1`.
- disk_size: size of disk that will be mounted on each vm.
- gateway: true to add a gateway for each vm.
- wg: true to add a wireguard access point to the network.
- add_public_ipv4: true to add public ipv4 to each vm.
- add_public_ipv6: true to add public ipv6 to each vm.
- ssh: public SSH key to access the any VM. should be in `~/.ssh/id_rsa.pub` on linux systems.
  
```sh
    v run vm.v --network main --mnemonic "YOUR MNEMONIC" --operation deploy --vm_name myvm --vm_network mynetwork --capacity small --times 3 --wg true --ssh "YOUR PUBLIC SSH KEY"
```

### Remove Operation Arguments

- vm_network: identifier for the vm network
- vm: name of the vm to be removed

```sh
    v run vm.v --network main --mnemonic "YOUR MNEMONIC" --operation remove --vm_network mynetwork --vm myvm
```

### Get Operation Arguments

- vm_network: identifier for the vm network

```sh
    v run vm.v --network main --mnemonic "YOUR MNEMONIC" --operation get --vm_network mynetwork
```

### Delete Operation Arguments

- vm_network: identifier for the vm network

```sh
    v run vm.v --network main --mnemonic "YOUR MNEMONIC" --operation delete --vm_network mynetwork
```
