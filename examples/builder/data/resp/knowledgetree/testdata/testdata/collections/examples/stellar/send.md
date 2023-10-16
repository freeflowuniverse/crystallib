# Send TFT example

## Prerequisites

- 2 Stellar accounts with at least 2 XLM and TFT Trustlines.
- The sending account needs TFT tokens

## run the example

- `-s`: stellar secret of the sending account
- `-d`: destination account
- `-m`: amount of TFT in string format (can be with decimals: "0.1")
- `-n`: network (testnet/public, default=public)

```sh
v -cg run send.v -s stellar_secret -d destination -m amount -n testnet
```
