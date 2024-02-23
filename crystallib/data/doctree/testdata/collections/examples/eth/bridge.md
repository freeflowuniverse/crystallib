# Bridge examples


## Prerequisites

To run this example on Stellar and Ethereum you need:

- Ethereum account with at least 0.01 ETH
- Stellar account with at least 2 XLM and TFT Trustline and TFT tokens

## Convert Stellar TFT to Ethereum TFT

- `-s`: stellar secret
- `-d`: destination ethereum account
- `-m`: amount of tft in string format (can be with decimals: "0.1")
- `-n`: network (testnet or public)

```sh
v -cg run convert_to_eth.v -m "100.50" -d destination_eth -n testnet -s stellar_s
```


## Convert Ethereum TFT to Stellar TFT

- `-s`: ethereum secret
- `-d`: destination stellar account
- `-m`: amount of tft in string format (can be with decimals: "0.1")
- `-e`: ethereum node url

```sh
v -cg run convert_to_stellar.v -s secret -d destination_stellar_addrr -m "100.50" -e https://goerli.infura.io/v3/your_infura_key
```


