 terraform {
  required_providers {
    grid = {
      source = "threefoldtech/grid"
    }
  }
}

provider "grid" {
    mnemonics = "@deployment.mnemonic"
    network = "test" # or test to use testnet
}

resource "grid_network" "net1" {
    nodes = [@nodeids]
    ip_range = "@deployment.network.iprange"
    name = "@net.name"
    description = "@net.description"
    add_wg_access = true
}


