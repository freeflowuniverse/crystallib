# Presearch Example

The presearch example exposes the following functionality:

- deploying a presearch instance with custom specs.
- reading a presearch instance from the grid.
- deleting a presearch instance from the grid.

## CLI Arguments

The [presearch cli](../../../../examples/tfgrid/presearch.v) has the following arguments:

- mnemonic: user mnemonic.
- network: chain network to use. defaults to `dev`
- address: address of web3proxy to connect to. defaults to `ws://127.0.0.1:8080`.
- operation: this is the operation that you want to perform. must be one of `deploy`, `get`, or `delete`.
- debug: true to print debug logs.

### Deploy Operation Arguments

- name: identifier for the instance, must be unique
- farm_id: farm id to deploy on, if 0, a random eligible node on a random farm will be selected. defaults to `0`.
- ssh: public SSH key to access the Presearch machine. should be in `~/.ssh/id_rsa.pub` on linux systems.
- disk_size: size of disk mounted on the presearch instance
- public_ipv4: true to add public ipv4 to presearch instance
- registration_code: You need to sign up on Presearch in order to get your Presearch Registration Code.
- public_restore_key: presearch public key for restoring old nodes
- private_restore_key: presearch private key for restoring old nodes
  
```sh
    v run presearch.v --network main --mnemonic "YOUR MNEMONIC" --operation deploy --name mypresearch --ssh "YOUR PUBLIC SSH KEY" --registration_code "YOUR REGISTRATION CODE"
```

### Get Operation Arguments

- name: name of the presearch instance

```sh
    v run presearch.v --network main --mnemonic "YOUR MNEMONIC" --operation get --name mypresearch
```

### Delete Operation Arguments

- name: name of the presearch instance

```sh
    v run presearch.v --network main --mnemonic "YOUR MNEMONIC" --operation delete --name mypresearch
```
