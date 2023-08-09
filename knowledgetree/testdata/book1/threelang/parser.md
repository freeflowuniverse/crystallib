# Threelang parser

Threelang is an intermediate language to tell the web3 proxy what to do. The language is markdown syntax augmented with actions. Actions tell the web3 proxy what to do. Each action contains a name and optionally parameters.

## Action properties

- an action is indicated in an md file by a line starting with !!
- actions are delimited by new lines.
- actions consist of:
  - action names
  - action parameters
  - action arguments
- an action name is the string following the "!!"
- action names consist of three parts separated by a ".", in this order:
  - module name
  - namespace
  - operation
- action parameters are all the key value pairs that follow an action name
- action arguments are all the single values that follow an action name
- parameters and arguments could be mixed toghether and do not have a particular order

### Module actions

- [TFGrid Actions](./tfgrid/grid_actions.md)
- [TFChain Actions](./tfchain/tfchain.md)
- [Web3GW Actions](./web3gw/actions.md)

## Example

- if a user wants to deploy a group of 4 machines on the same network:
  
```md
    !!tfgrid.machine.create
        name: 'my machines'
        ssh_key: 'ssh_key'
        times: 4
        capacity: medium
```

- this would deploy 4 vms, with medium capacity (cru, mru, sru) on the same network.

### Usage

Use web3proxy functionality by providing markdown files containing threelang the script [here](../../../examples/threelang/threelang.v).

  ```v
  v run threelang.v -f <file_path>
  ```
