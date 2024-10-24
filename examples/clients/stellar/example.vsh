#!/usr/bin/env -S v -gc none -no-retry-compilation -cc tcc -d use_openssl -enable-globals run

import freeflowuniverse.crystallib.blockchain.stellar

mut client := stellar.new_stellar_client(network: 'testnet', default_account: 'mario')!


client.add_keys(secret: 'SAAK2IJ5VNN453BQMDBR3WIL4TSBATIAW6I5QGKPUQZ6YBRON2HXU7N2')!
client.add_signer(address: 'GAAEAXBM2BTW4SK6Z4OZRWVNH4KM5PUF7RR746EBEWH5NMSUZTU6U7AK')!
client.remove_signer(address: 'GAAEAXBM2BTW4SK6Z4OZRWVNH4KM5PUF7RR746EBEWH5NMSUZTU6U7AK')!
client.merge_accounts(address: 'GAAEAXBM2BTW4SK6Z4OZRWVNH4KM5PUF7RR746EBEWH5NMSUZTU6U7AK')!