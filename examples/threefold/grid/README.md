# Installing `griddriver`

To be able to run examples you need to install updated version of `griddriver`.

## Install from crytallib installer

Create some `griddriver_install.vsh` file containing following code:

```vlang
#!/usr/bin/env -S v -n -w -enable-globals run

import freeflowuniverse.crystallib.installers.tfgrid.griddriver as griddriverinstaller

mut reset:=true
griddriverinstaller.install(reset:reset)!
```

Make script executable and run it

```sh
chmod +x ./griddriver_install.vsh
./griddriver_install.vsh
```

## Install from repo

Checkout the `griddriver` main branch
https://github.com/threefoldtech/web3gw/tree/development_integration

Inside the web3gw directory, run:

```sh
cd griddriver
./build.sh
```

# Run examples

These example scripts demonstrate various functionalities and interactions with
the TFGrid using the Crystal programming language. They provide a starting point
for developers to understand and build upon when working with the TFGrid API and
deploying resources on the grid.

## Utils

-   `billing_hourly.vsh`: calculate the hourly billing for a specific contract
    ID.
-   `cancel_contract.vsh`: cancel a specific contract on the TFGrid.
-   `cancel_contracts.vsh`: cancel multiple contracts on the TFGrid.
-   `deploy_vm_high_level.vsh`: deploy a virtual machine (VM) on the TFGrid
    using a high-level approach.
-   `get_contracts.vsh`: retrieve a list of all active contracts associated with
    the configured identity on the TFGrid.
-   `list_gateways.vsh`: list all available gateways on the TFGrid.
-   `tfgrid_config.vsh`: configure the connection settings for interacting with
    the TFGrid.
-   `zos_version.vsh`: check the version of the Zero-OS (ZOS) running on a
    specific node.

## Tests

-   `create_update_deployments.vsh`: create a deployment with various workloads
    (network, disk, public IP, VM, logs, ZDB) and a gateway name proxy, deploy
    it to a node, and update the deployment with the gateway name workload.
-   `deploy_gw_fqdn.vsh`: deploy a gateway workload using a Fully Qualified
    Domain Name (FQDN).
-   `deploy_gw_name.vsh`: deploy a gateway workload using a name contract. It
    creates a GatewayNameProxy workload, reserves the name on the grid using a
    name contract, and deploys it to a specific node.
-   `deploy_vm.vsh`: deploy a network (Znet) and a virtual machine (Zmachine).
-   `deploy_zdb.vsh`: deploy a ZDB (Zero-DB) workload on a specific node.
-   `holochain_vm.vsh`: set up a Holochain development environment on the
    ThreeFold Grid without manual configuration. The script is related to
    Holochain because it specifically deploys a Holochain development
    environment on the ThreeFold Grid. The Flist URL used in the virtual machine
    workload points to a pre-built Holochain development environment image.
    Usage:

```sh
./holochain_vm.vsh --mnemonic "your_mnemonic_phrase" --ssh_key "your_public_ssh_key" [--network main|test|qa|dev] [--code_server_pass "your_password"] [--cpu 4] [--ram 8] [--disk 30] [--public_ip]
```

-   `vm_with_gw_name.vsh`: deploy a VM workload along with a gateway using a
    name contract. It finds a node matching the VM capacity requirements,
    creates a network, a VM, and a gateway workload pointing to the VM. It then
    deploys the VM and gateway workloads to their respective nodes. Usage:

```sh
./vm_with_gw_name.vsh --mnemonic "your_mnemonic_phrase" --ssh_key "your_public_ssh_key" [--network main|test|qa|dev] [--cpu 4] [--ram 4] [--disk 5] [--public_ip]
```
