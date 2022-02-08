 terraform {
  required_providers {
    grid = {
      source = "threefoldtech/grid"
    }
  }
}

provider "grid" {
    mnemonics = "@deployment.mnemonic"
    network = "@deployment.tfgrid_net_string()" 
}

resource "grid_network" "net1" {
    nodes = [@nodeids]
    ip_range = "@deployment.network.iprange"
    name = "@net.name"
    description = "@net.description"
    add_wg_access = true
}


