# Bridge examples

## Prerequisites

To run this example on Stellar testnet and Ethereum testnet you need:

- Stellar testnet account with at least 10 XLM and TFT Trustline + TFT
- Ethereum testnet account with at least 0.01 ETH on Goerli network

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
