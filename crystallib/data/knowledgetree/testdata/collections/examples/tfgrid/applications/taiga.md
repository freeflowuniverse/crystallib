# Taiga Example

The taiga example exposes the following functionality:

- deploying a taiga instance with custom specs.
- reading a taiga instance from the grid.
- deleting a taiga instance from the grid.

## CLI Arguments

The [taiga cli](../../../../examples/tfgrid/applications/taiga.v) has the following arguments:

- mnemonic: user mnemonic.
- network: chain network to use. defaults to `dev`
- address: address of web3proxy to connect to. defaults to `ws://127.0.0.1:8080`.
- operation: this is the operation that you want to perform. must be one of `deploy`, `get`, or `delete`.
- debug: true to print debug logs.

### Deploy Operation Arguments

- name: identifier for the instance, must be unique
- farm_id: farm id to deploy on, if 0, a random eligible node on a random farm will be selected. defaults to `0`.
- capacity: capacity of the taiga instance. must be one of `small`, `medium`, `large`, or `extra-large`. defaults to `medium`.
- ssh: public SSH key to access the Taiga machine. should be in `~/.ssh/id_rsa.pub` on linux systems.
- admin_username: admin username
- admin_password: admin password
- admin_email: admin email
  
```sh
    v run taiga.v --network main --mnemonic "YOUR MNEMONIC" --operation deploy --name mytaiga --capacity small --ssh "YOUR PUBLIC SSH KEY"
```

### Get Operation Arguments

- name: name of the taiga instance

```sh
    v run taiga.v --network main --mnemonic "YOUR MNEMONIC" --operation get --name mytaiga
```

### Delete Operation Arguments

- name: name of the taiga instance

```sh
    v run taiga.v --network main --mnemonic "YOUR MNEMONIC" --operation delete --name mytaiga
```
