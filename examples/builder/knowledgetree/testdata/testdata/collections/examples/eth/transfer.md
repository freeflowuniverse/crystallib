# Transfer examples

## Prerequisites

- Ethereum account with at least 0.01 ETH

## Transfer Ethereum

- `-s`: ethereum secret
- `-d`: destination ethereum account
- `-m`: amount of eth in string format (can be with decimals: "0.1")
- `-e`: ethereum node url

```sh
v -cg run transfer_eth.v -m "0.0000001" -d destination_eth -s secret -e https://goerli.infura.io/v3/your_infura_key
```

## Transfer TFT on Ethereum

- `-s`: ethereum secret
- `-d`: destination ethereum account
- `-m`: amount of tft in string format (can be with decimals: "0.1")
- `-e`: ethereum node url

```sh
v -cg run transfer_tft.v -m "100.50" -d destination_eth -s secret -e https://goerli.infura.io/v3/your_infura_key
```