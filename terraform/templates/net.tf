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
    ip_range = "10.1.0.0/16"
    name = "@net.name"
    description = "@net.description"
    add_wg_access = true
}


