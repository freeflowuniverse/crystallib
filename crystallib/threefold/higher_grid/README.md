# Higher Grid Client V Modules

This project provides a V modules (`models.v`) that interacts with the [ThreeFold Grid](https://manual.grid.tf/documentation/developers/grid_deployment/grid_deployment.html) to manage the deployment, listing, and deletion of virtual machines (VMs) on the ThreeFold grid using the `freeflowuniverse.crystallib.threefold.grid` library. The module handles workloads creation, network setup, and deployment processes.

## Features

- **Deploy Virtual Machines (VMs):** Deploy workloads (VMs and networks) to a specific node on the ThreeFold Grid.
- **List Deployments:** Retrieve active deployments and contracts on the ThreeFold network.
- **Delete Deployments:** Remove an active deployment by its name.
- **Fetch Deployment Results:** Obtain the results of a specific deployment.
- **Manage Network Workloads:** Automatically assign WireGuard ports and configure virtual networks.
- **Public IP Management:** Manage IPv4 and IPv6 configurations for public access to VMs.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
  - [Deployment](#deployment)
  - [Listing Deployments](#listing-deployments)
  - [Deleting a Deployment](#deleting-a-deployment)
  - [Fetching Deployment Results](#fetching-deployment-results)
- [Environment Variables](#environment-variables)
- [Examples](#examples)

## Installation

1. Install the `v` programming language by following the instructions [here](https://vlang.io).
2. Clone the repository and ensure that you have linked the crystallib repository with the smae repository in the `.vmodules` in your system.

```bash
git clone https://github.com/freeflowuniverse/crystallib.git
cd crystallib
```

## Usage

### Deployment

To deploy VMs on the ThreeFold Grid, create a `GridMachinesModel` with the necessary configuration, such as the machine names, network access, and capacity requirements. Then call the `deploy` method.

```v
import freeflowuniverse.crystallib.threefold.higher_grid.models

mnemonic := os.getenv('TFGRID_MNEMONIC')
ssh_key := os.getenv('SSH_KEY')

// Create the GridConfig for deployment
// Assuming "dev" is the chain network
mut grid := models.new_grid_client(mnemonic, .dev, ssh_key)!

mut vms := models.GridMachinesModel{
    name: "MyVMDeployment",
    node_id: 177,
    network: models.NetworkModel{
        name: "MyNetwork",
        ip_range: '10.249.0.0/16',
        subnet: '10.249.0.0/24',
    },
    machines: [
        models.MachineModel{
            name: "MyVM",
            network_access: models.MachineNetworkAccessModel{
                public_ip4: false,
                public_ip6: false,
                planetary: true,
                mycelium: true,
            },
            capacity: models.ComputeCapacity{
                cpu: 4,
                memory: 4096,
            },
        }
    ]
}

grid.machines.deploy(vms)!
```

### Listing Deployments

To list all active deployments associated with the current twin:

```v
deployments := grid.machines.list()!
for deployment in deployments {
    println(deployment)
}
```

### Deleting a Deployment

To delete a deployment by name:

```v
grid.machines.delete("MyVMDeployment")!
```

### Fetching Deployment Results

To retrieve the results of a specific deployment:

```v
deployment_results := grid.machines.get("MyVMDeployment")!
println(deployment_results)
```

## Environment Variables

The following environment variables must be set to enable the module to interact with the ThreeFold Grid:

- `TFGRID_MNEMONIC`: The mnemonic phrase used to authenticate with the ThreeFold Grid.
- `SSH_KEY`: Your SSH key for accessing deployed VMs.

```bash
export TFGRID_MNEMONIC="your-mnemonic-phrase-here"
export SSH_KEY="your-ssh-key-here"
```

## Examples

The example below shows how to define and deploy a virtual machine, retrieve the deployment result, and delete the deployment.

```v
fn do()! {
    mnemonic := os.getenv('TFGRID_MNEMONIC')
    ssh_key := os.getenv('SSH_KEY')

    // Create the Grid Client for deployment
    mut grid := models.new_grid_client(mnemonic, .dev, ssh_key)!

    // Define the VMs to be deployed
    mut vms := models.GridMachinesModel{
        name: "MachinesInterface",
        node_id: 177,
        network: models.NetworkModel{
            name: "MyNetwork",
            ip_range: '10.249.0.0/16',
            subnet: '10.249.0.0/24',
        },
        machines: [
            models.MachineModel{
                name: "MyVM",
                network_access: models.MachineNetworkAccessModel{
                    public_ip4: false,
                    public_ip6: false,
                    planetary: true,
                },
                capacity: models.ComputeCapacity{
                    cpu: 4,
                    memory: 2048,
                },
            }
        ]
    }

    // Deploy the VMs
    grid.machines.deploy(vms)!
    
    // Retrieve and print the deployments
    deployments := grid.machines.get("MachinesInterface")!
    println(deployments)

    // Delete the deployment
    grid.machines.delete("MachinesInterface")!
}

fn main() {
    do()!
}
```
