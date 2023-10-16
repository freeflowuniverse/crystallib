# Stellar

## Creating an account

You can create a stellar account through the rpc createaccount which only requires one argument: the network the account should be created on. It will return the seed in the result. 

Take a look at [the stellar rpc documentation](../../rpc/stellar.md#creating-an-account) to see what to send to the server.

## Loading your key

Before you can execute any other rpc (except for createaccount) you have to call the load rpc. This will start your session and requires you to specify your secret and the network you want to connect to. If everything went well it will return an empty json rpc 2.0 response. 

Take a look at [the stellar rpc documentation](../../rpc/stellar.md#loading-your-key) to see what to send to the server.

## Asking your public address

Once your secret key has been loaded you can ask for your public address via the address rpc. This will return the public address in a json rpc 2.0 response. 

Take a look at [the stellar rpc documentation](../../rpc/stellar.md#asking-your-public-address) to see what to send to the server.

## Transfer tokens from one account to another

The rpc transfer allows you to transfer tokens from one account to the other. It requires you to provide the amount, the destination account and a memo. This will return the hash of the transaction in a json rpc 2.0 response.

Take a look at [the stellar rpc documentation](../../rpc/stellar.md#transfer-tokens-from-one-account-to-another) to see what to send to the server.

## Swap tokens from one asset to the other

It is possible to swap your lumen tokens to tft and visa versa with the rpc swap. It requires the amount, the source asset and the destination asset. Both the source and destination assets should be one of tft or xlm, meaning we can only swap tfts to lumen and visa versa. This will return the hash of the transaction in a json rpc 2.0 response.

Take a look at [the stellar rpc documentation](../../rpc/stellar.md#swap-tokens-from-one-asset-to-the-other) to see what to send to the server.

## Get the balance of an account

You can as for the balance of an account with the rpc balance. The account to ask the balance of can be send via the parameters. If it is not present in the parameters the balance will be returned of the account that is currently loaded. The response will contain the balance of the account. 

Take a look at [the stellar rpc documentation](../../rpc/stellar.md#get-the-balance-of-an-account) to see what to send to the server.

## Bridge stellar tft to ethereum

You can convert your TFTs on stellar to TFTs on ethereum with the call to bridgetoeth. This call will require you to pass the amount of tft to bridge and the account that should receive the tokens. The response of the server will contain the hash of the transaction on the bridge. 

Take a look at [the stellar rpc documentation](../../rpc/stellar.md#bridge-stellar-tft-to-ethereum) to see what to send to the server.

## Bridge stellar tft to tfchain

Similarly to bridging to ethereum you can also convert your TFTs on stellar to TFTs on tfchain with the call to bridgetotfchain. You should provide the amount and the destination twin id that will receive the tokens. The response will contain the hash of the transaction on the bridge. 

Take a look at [the stellar rpc documentation](../../rpc/stellar.md#bridge-stellar-tft-to-tfchain) to see what to send to the server.

## Waiting for a transaction on the Ethereum bridge

This is a usefull call in case you are bridging from ethereum to stellar (transfering tft from ethereum to stellar). Once the ethereum has been transferred to the bridge it's time to wait until the bridge executes a similar transaction on stellar (so that the stellar account is receiving the tfts send from the ethereum account). This is what the rpc awaittransactiononethbridge does. It requires the memo of the transaction which is predictable when executing the call to bridge the tokens. If the transaction is found within the next 5 minutes it will return an empty result which means it found the transaction. 

Take a look at [the stellar rpc documentation](../../rpc/stellar.md#waiting-for-a-transaction-on-the-ethereum-bridge) to see what to send to the server.

## Listing transactions

You can get the transactions of an account via the rpc transactions. Just provide the account, the limit, whether or not to include failed transactions, the cursor and the order the transactions should be in. All of these parameters are optional. Leaving the account empty will result in showing the transactions of the account that is loaded. There is a default limit of 10 transactions, the default cursor is the top (latest), by default we do not show failed transactions and the transactions are by default in descending order. The server will return the transactions in a json rpc response. Please look [here](https://github.com/stellar/go/blob/01c7aa30745a56d7ffcc75bb8ededd38ba582a58/protocols/horizon/main.go#L484) to see the definition of a transaction.

Take a look at [the stellar rpc documentation](../../rpc/stellar.md#listing-transactions) to see what to send to the server.

## Showing the data related to an account

You can get more information about your account (or any other account) through the rpc accountdata. It has only one parameter: the account to get the data for. The account data will be in the result if the account exists. Please take a look [here](https://github.com/stellar/go/blob/01c7aa30745a56d7ffcc75bb8ededd38ba582a58/protocols/horizon/main.go#L33) to get the definition of the account data. 

Take a look at [the stellar rpc documentation](../../rpc/stellar.md#showing-the-data-related-to-an-account) to see what to send to the server.
