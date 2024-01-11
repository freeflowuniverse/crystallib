# K8s Example

The k8s example exposes the following functionality:

- deploying a k8s instance with custom specs.
- adding a k8s worker node to a pre-existing cluster.
- removeing a k8s worker node from a pre-existing cluster.
- reading a k8s instance from the grid.
- deleting a k8s instance from the grid.

## CLI Arguments

The [k8s cli](../../../../examples/tfgrid/k8s.v) has the following arguments:

- mnemonic: user mnemonic.
- network: chain network to use. defaults to `dev`
- address: address of web3proxy to connect to. defaults to `ws://127.0.0.1:8080`.
- operation: this is the operation that you want to perform. must be one of `deploy`, `add`, `remove`, `get`, or `delete`.
- debug: true to print debug logs.

### Deploy Operation Arguments

- name: Name of the cluster
- token: Token for the cluster, used to let workers join the cluster. defaults to a random string from 20 english letter characters.
- ssh: public SSH Key to access any cluster node. should be in `~/.ssh/id_rsa.pub` on linux systems.
- workers: Number of workers to add to the cluster. defaults to `1`.
- farm_id: Farm id to deploy on, if 0, a random eligible node on a random farm will be selected for each cluster node. defaults to `0`.
- capacity: capacity of the cluster nodes. must be one of `small`, `medium`, `large`, or `extra-large`. defaults to `medium`.
- public_ip: True to add public ips for each cluster node. defaults to `false`
  
```sh
    v run k8s.v --network main --mnemonic "YOUR MNEMONIC" --operation deploy --name myk8s --capacity small --ssh "YOUR SSH KEY"
```

### Add Operation Arguments

- name: name of the k8s instance
- farm_id: farm id to deploy on, if 0, a random eligible node on a random farm will be selected. defaults to `0`.
- capacity: capacity of the k8s instance. must be one of `small`, `medium`, `large`, or `extra-large`. defaults to `medium`.
- public_ip: True to add a public ip for the new worker. defaults to `false`.

```sh
    v run k8s.v --network main --mnemonic "YOUR MNEMONIC" --operation add --name myk8s --public_ip true --capacity small
```

### Remove Operation Arguments

- name: name of the k8s instance

```sh
    v run k8s.v --network main --mnemonic "YOUR MNEMONIC" --operation remove --name myk8s --worker_name wr123456
```

### Get Operation Arguments

- name: name of the k8s instance

```sh
    v run k8s.v --network main --mnemonic "YOUR MNEMONIC" --operation get --name myk8s
```

### Delete Operation Arguments

- name: name of the k8s instance

```sh
    v run k8s.v --network main --mnemonic "YOUR MNEMONIC" --operation delete --name myk8s
```
