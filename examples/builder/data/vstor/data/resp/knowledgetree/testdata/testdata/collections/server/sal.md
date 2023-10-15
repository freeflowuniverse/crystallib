# SAL

## Tfgrid

### Load
- loads key
- chooses network
- starts session and creates state for client

```
func (c *Client) Load(args Load) error
```

### DeployVM
- Deploy a single VM 
- Choose node id, farm id, etc 

```
func (c *Client) DeployVM(args tfgridBase.VMDeployment) (tfgridBase.VMDeployment, error)
```

### GetVMDeployment
- Retrieve information about the deployed vm

```
func (c *Client) GetVMDeployment(name string) (tfgridBase.VMDeployment, error)
```

### CancelVMDeployment
- Cancel the vm deployment

```
func (c *Client) CancelVMDeployment(name string) error
```

### DeployNetwork
- Deploy VMs that will be in the same network
- Provide name and network specs
- Provide the VM specs (on what node, farmid, flist, etc.)

```
func (c *Client) DeployNetwork(args tfgridBase.NetworkDeployment) (tfgridBase.NetworkDeployment, error)
```

### GetNetworkDeployment
- Retrieve information about the vms you deployed by providing the name when deploying
```
func (c *Client) GetNetworkDeployment(name string) (tfgridBase.NetworkDeployment, error)
```

### CancelNetworkDeployment
- Delete all deployed VMs that are part of the model that goes by the modelName

```
func (c *Client) CancelNetworkDeployment(name string) error
```

### ExtendNetworkDeployment
- Add a VM to the network
```
func (c *Client) ExtendNetworkDeployment(args tfgridBase.ExtendNetworkDeployment) (tfgridBase.NetworkDeployment, error)
```

### ShrinkNetworkDeployment
- Remove a VM from the network
```
func (c *Client) ShrinkNetworkDeployment(args tfgridBase.ShrinkNetworkDeployment) (tfgridBase.NetworkDeployment, error)
```

### DeployK8SCluster
- Deploys K8S cluster

```
func (c *Client) DeployK8SCluster(args tfgridBase.K8SCluster) (tfgridBase.K8SCluster, error)
```

### GetK8SCluster
- Retrieve information about the K8S cluster

```
func (c *Client) GetK8SCluster(args tfgridBase.GetK8SCluster) (tfgridBase.K8sCluster, error)
```

### CancelK8S
- Cancel K8S cluster

```
func (c *Client) CancelK8SCluster(name string) error 
```

### AddWorkerToK8sCluster
- Extend the K8S cluster with an extra worker
- Provide what you need to add the worker (node id, farm id, etc)

```
func (c *Client) AddWorkerToK8sCluster(args tfgridBase.AddWorkerToK8sCluster) (tfgridBase.K8sCluster, error) 
```

### RemoveWorkerFromK8sCluster

```
func (c *Client) RemoveWorkerFromK8sCluster(args tfgridBase.RemoveWorkerFromK8sCluster) (tfgridBase.K8sCluster, error)
```

### DeployZDB
- Deploy a ZDB
- Provide everything required to deploy the zero db (size, node id, etc)

```
func (c *Client) DeployZDB(args tfgridBase.ZDBDeployment) (tfgridBase.ZDBDeployment, error) 
```

### GetZDB
- Retrieve information about the deployed ZDB

```
func (c *Client) GetZDB(name string) (tfgridBase.ZDBDeployment, error) 
```

### CancelZDB
- Cancel the ZDB deployment

```
func (c *Client) CancelZDB(name string) error 
```

### DeployGatewayName
- Deploy a gateway name
```
func (c *Client) DeployGatewayName(args tfgridBase.GatewayName) (tfgridBase.GatewayName, error) 
```

### GetGatewayName
- Retrieve the gateway name information

```
func (c *Client) GetGatewayName(name string) (tfgridBase.GatewayName, error)
```

### CancelGatewayName
- Cancel the gateway name

```
func (c *Client) CancelGatewayName(name string) error
```

### DeployGatewayFQDN
- Deploy Gateway Fully Qualified Domain Name

```
func (c *Client) DeployGatewayFQDN(args tfgridBase.GatewayFQDN) (tfgridBase.GatewayFQDN, error) 
```

### GetGatewayFQDN
- Retrieve information about FQDN by providing the name

```
func (c *Client) GetGatewayFQDN(name string) (tfgridBase.GatewayFQDN, error)
```

### CancelGatewayFQDN
- Cancel the gateway FQDN

```
func (c *Client) CancelGatewayFQDN(name string) error
```

### FindNodes
- Find nodes with specific filters

```
func (c *Client) FindNodes(args FindNodes) (NodesResult, error)
```

### FindFarms
- Find farms with specific filters

```
func (c *Client) Farms(args FindFarms) (FarmsResult, error)
```

### FindContracts
- Find contracts with specific filters

```
func (c *Client) Contracts(args FindContracts) (ContractsResult, error)
```

### FindTwins
- Find twins with specific filters

```
func (c *Client) Twins(params FindTwins) (TwinsResult, error)
```

### Statistics
- Get statistics of the grid (amount of nodes, farms, countries, cru, etc.)

```
func (c *Client) Counters(filters proxyTypes.StatsFilter) (proxyTypes.Counters, error)
```

### DeployDiscourse
- Deploy vm that has discource on it

```
func (c *Client) DeployDiscourse(args tfgridBase.DeployDiscourse) (tfgridBase.DiscourceDeployment, error)
```

### GetDiscourceDeployment
- Retrieve information about the discource deployment (ip, etc)

```
func (c *Client) GetDiscourceDeployment(name string) (tfgridBase.DiscourceDeployment, error)
```

### CancelDiscourceDeployment
- Cancel the discource deployment

```
func (c *Client) CancelDiscourceDeployment(name string) error
```

### DeployFunkwhale
- Deploy vm that has funkwhale on it

```
func (c *Client) DeployFunkwhale(args tfgridBase.Funkwhale) (tfgridBase.FunkwhaleDeployment, error)
```

### GetFunkwhaleDeployment
- Retrieve information about the funkwhale deployment (ip, etc)

```
func (c *Client) GetFunkwhaleDeployment(name string) (tfgridBase.FunkwhaleDeployment, error) 
```

### CancelFunkwhaleDeployment
- Cancel the funkwhale deployment

```
func (c *Client) CancelFunkwhaleDeployment(name string) error
```

### DeployPeertube
- Deploy vm that has peertube on it

```
func (c *Client) DeployPeertube(args tfgridBase.Peertube) (tfgridBase.PeertubeDeployment, error)
```

### GetPeertubeDeployment
- Retrieve information about the peertube deployment (ip, etc)

```
func (c *Client) GetPeertubeDeployment(name string) (tfgridBase.PeertubeDeployment, error)
```

### CancelPeertubeDeployment
- Cancel the discource deployment


```
func (c *Client) CancelPeertubeDeployment(name string) error
```

### DeployPresearch
- Deploy vm that has presearch on it

```
func (c *Client) DeployPresearch(args tfgridBase.Presearch) (tfgridBase.PresearchDeployment, error)
```

### GetPresearchDeployment
- Retrieve information about the presearch deployment (ip, etc)

```
func (c *Client) GetPresearchDeployment(name string) (tfgridBase.PresearchDeployment, error)
```

### CancelPresearchDeployment
- Cancel the discource deployment

```
func (c *Client) CancelPresearchDeployment(name string) error
```

### DeployTaiga
- Deploy vm that has taiga on it

```
func (c *Client) DeployTaiga(taiga tfgridBase.Taiga) (tfgridBase.TaigaDeployment, error) 
```
### GetTaigaDeployment
- Retrieve information about the taiga deployment (ip, etc)

```
func (c *Client) GetTaigaDeployment(taigaName string) (tfgridBase.TaigaResult, error)
```

### CancelTaigaDeployment
- Cancel the discource deployment

```
func (c *Client) CancelTaigaDeployment(name string) error 
```

## Stellar

### Load
- loads key
- chooses network
- starts session and creates state for client

```
func (c *Client) Load(args Load) error
```

### CreateAccount
- Creates account on stellar given the network

```
func (c *Client) CreateAccount(network string) (string, error)
```

### Address
- Get the stellar public address of the loaded secret

```
func (c *Client) Address() (string, error)
```

### Transactions
- Get the last transactions of your account

```
func (c *Client) Transactions(args Transactions) ([]horizon.Transaction, error)
```

### Height
- Height of the chain for the connected rpc remote

```
func (c *Client) Height() (uint64, error)
```

### AccountData
- Get data related to a stellar account, leave account empty for account data of loaded account

```
func (c *Client) AccountData(account string) (horizon.Account, error)
```

### Swap
- Swap tokens from one asset to the other (xlm to tft, etc)

```
func (c *Client) Swap(args Swap) error
```

### Transfer
- Transfer tokens from one account to the other on stellar chain

```
func (c *Client) Transfer(args Transfer) (string, error)
```

### Balance
- Get the balance of a specific address
- If address is empty the balance of the loaded account will be returned
- You can ask the balance of different assets (tft, xlm), default will be xlm

```
Balance struct {
	Address    string `json:"address"`
	Asset      string `json:"asset"`
}

func (c *Client) Balance(args Balance) (string, error)
```

### BridgeToEth
- Bridge tokens of your stellar account to an account on ethereum

```
BridgeToEth(args BridgeTransfer) (string, error)
```

### BridgeToTfchain
- Bridge tokens of your stellar account to an account on tfchain (provide twinid)

```
func (c *Client) BridgeToTfchain(args TfchainBridgeTransfer) (string, error)
```

### AwaitBridgedFromEthereum
- Await till a transaction is processed on ethereum bridge that contains a specific memo, that transaction is the result of a bridge from ethereum to the loaded stellar account

```
AwaitBridgedFromEthereum struct {
    Memo                        string `json:"memo"` // the memo to look for 
    Timeout                     int    `json:"timeout"` // the timeout after which we abandon the search 
    AmountOfTransactionsToCheck int    `json:"history_size"`  // how many transactions we check in one go
}   

func (c *Client) AwaitBridgedFromEthereum(args AwaitBridgedFromEthereum) error
```

## Ethereum

### Load
- loads key
- chooses network
- starts session and creates state for client

```
func (c *Client) Load(args Load) error
```

### Balance
- Balance of an address, if address is empty the balance of the loaded account will be returned                                    
- Provide the asset to get the balance of (eth, tft)

```
func (c *Client) Balance(args Balance) (string, error)
```

### Height
- Height of the chain for the connected rpc remote

```
func (c *Client) Height() (uint64, error)
```

### Transfer
- Transer an amount of Eth from the loaded account to the destination. The transaction ID is returned.

```
Transfer struct {
	Amount      string `json:"amount"` // how much should be transfered
	Destination string `json:"destination"` // the eth public address of the destination account 
    Asset       string `json:"asset"` // the asset to transfer to the destination account, default will be eth
}
func (c *Client) Transfer(args Transfer) (string, error)
```

### Quote
- quote a swap of asset

```
func (c *Client) Quote(args Quote) (string, error)
```

### Swap
- Swap tokens from one asset to the other (eth to tft, etc)

```
func (c *Client) Swap(args Swap) (string, error)
```

### BridgeToStellar
- withdraws eth tft to stellar

```
TftTransfer struct {
	Amount      string `json:"amount"` // how much should be transfered
	Destination string `json:"destination"` // the eth public address of the destination account 
}
func (c *Client) BridgeToStellar(args TftTransfer) (string, error)
```

### ApproveTftSpending
- approves the given amount of TFT to be swapped

```
func (c *Client) ApproveTftSpending(amount string) (string, error)
```

### GetTftSpendingAllowance
- returns the amount of TFT approved to be swapped

```
func (c *Client) GetTftSpendingAllowance() (string, error)
```

### Address
- Address of the loaded client

```
func (c *Client) Address() (string, error)
```

### CreateStellarAccount
- Creates and activates stellar account using ethereum

```
func (c *Client) CreateStellarAccount(network string) (string, error)
```

### GetTokenBalance
- GetTokenBalance fetches the balance for an erc20 compatible contract

```
func (c *Client) GetTokenBalance(contractAddress string) (string, error)
```

### TransferTokens
- transfers an erc20 compatible token to a destination

```
func (c *Client) TransferTokens(args TokenTransfer) (string, error)
```

### TransferTokensFrom
- transfers tokens from an account to another account (can be executed by anyone that is approved to spend)

```
func (c *Client) TransferFromTokens(args TokenTransferFrom) (string, error)
```

### ApproveTokenSpending
- approves spending from a token contract with a limit

```
func (c *Client) ApproveTokenSpending(args ApproveTokenSpending) (string, error)
```

### GetFungibleBalance
- returns the balance of the given address for the given fungible token contract

```
func (c *Client) GetFungibleBalance(args GetFungibleBalance) (string, error)
```

### OwnerOfFungible
- returns the owner of the given fungible token

```
func (c *Client) OwnerOfFungible(args OwnerOfFungible) (string, error)
```

### SafeTransferFungible
- transfers a fungible token from the given address to the given target address

```
func (c *Client) SafeTransferFungible(args TransferFungible) (string, error)
```

### TransferFungible
- transfers the given fungible token from the given address to the given target address

```
func (c *Client) TransferFungible(args TransferFungible) (string, error)
```

### SetFungibleApproval
- approves the given address to spend the given tokenId of the given fungible token

```
func (c *Client) SetFungibleApproval(args SetFungibleApproval) (string, error)
```

### SetFungibleApprovalForAll
- approves the given address to spend all the given fungible tokens

```
func (c *Client) SetFungibleApprovalForAll(args SetFungibleApprovalForAll) (string, error)
```

### GetApprovalForFungible
- returns whether the given address is approved to spend the given tokenId of the given fungible token

```
func (c *Client) GetApprovalForFungible(args ApprovalForFungible) (bool, error)
```

### GetApprovalForAllFungible
- returns whether the given address is approved to spend all the given fungible tokens

```
func (c *Client) GetApprovalForAllFungible(args ApprovalForFungible) (bool, error)
```

### GetMultisigOwners
- fetches the owner addresses for a multisig contract

```
func (c *Client) GetMultisigOwners(contractAddress string) ([]string, error)
```

### GetMultisigThreshold
- fetches the treshold for a multisig contract

```
func (c *Client) GetMultisigThreshold(contractAddress string) (string, error)
```

### AddMultisigOwner
- adds an owner to a multisig contract

```
func (c *Client) AddMultisigOwner(args MultisigOwner) (string, error)
```

### RemoveMultisigOwner
- adds an owner to a multisig contract

```
func (c *Client) RemoveMultisigOwner(args MultisigOwner) (string, error)
```

### ApproveHash
- approves a transaction hash

```
func (c *Client) ApproveHash(args ApproveHash) (string, error)
```

### IsApproved
- checks if a transaction hash was approved

```
func (c *Client) IsApproved(args ApproveHash) (bool, error)
```

### InitiateMultisigEthTransfer
- initiates a multisig eth transfer operation

```
func (c *Client) InitiateMultisigEthTransfer(args InitiateMultisigEthTransfer) (string, error)
```

### InitiateMultisigTokenTransfer
- initiates a multisig eth transfer operation

```
func (c *Client) InitiateMultisigTokenTransfer(args InitiateMultisigTokenTransfer) (string, error)
```

## Nostr

### Load
- loads key
- starts session and creates state for client

```
func (c *Client) Load(args Load) error
```

### ID
- returns the nostr ID for the client

```
func (c *Client) GetId() (string, error)
```

### GetPublicKey
- returns the public key of the client in hex

```
func (c *Client) GetPublicKey() (string, error)
```

### ConnectToAuthRelay
- connects to an authenticated relay with a given url

```
func (c *Client) ConnectToAuthRelay(url string) error
```

### ConnectToRelay
- connects to a relay with a given url

```
func (c *Client) ConnectToRelay(url string) error
```

### GenerateKeyPair
- generates a new keypair

```
func (c *Client) GenerateKeyPair(ctx context.Context) (string, error)
```

### PublishTextNote
- publishes a text note to all relays

```
func (c *Client) PublishTextNote(input TextInput) error
```

### PublishMetadata
- publishes metadata to all relays

```
func (c *Client) PublishMetadata(input MetadataInput) error
```

### PublishDirectMessage
- publishes a direct message to a receiver

```
func (c *Client) PublishDirectMessage(input DirectMessageInput) error
```

### SubscribeTextNotes
- subscribes to text notes on all relays

```
func (c *Client) SubscribeTextNotes() (string, error)
```

### SubscribeDirectMessages 
- subscribes to direct messages on all relays and decrypts them

```
func (c *Client) SubscribeDirectMessages() (string, error)
```

### SubscribeStallCreation
- subscribes to stall creation on all relays

```
func (c *Client) SubscribeStallCreation() (string, error)
```

### SubscribeProductCreation
- subscribes to product creation on all relays

```
func (c *Client) SubscribeProductCreation() (string, error)
```

### CloseSubscription
- closes a subscription by id

```
func (c *Client) CloseSubscription(id string) error
```

### GetSubscriptionIds
- returns all subscription ids

```
func (c *Client) GetSubscriptionIds() ([]string, error)
```

### GetEvents
- returns all events for all subscriptions

```
func (c *Client) GetEvents() ([]nostr.NostrEvent, error)
```

### PublishStall
- publishes a new stall to the relay

```
func (c *Client) PublishStall(input StallInput) error
```

### PublishProduct
- publishes a new product to the relay

```
func (c *Client) PublishProduct(input ProductInput) error
```

### CreateChannel 
- creates a new channel

```
func (c *Client) CreateChannel(input CreateChannelInput) (string, error)
```

### SubscribeChannelCreation
- subscribes to channel creation events on the relay

```
func (c *Client) SubscribeChannelCreation() (string, error)
```

### CreateChannelMessage
- creates a channel message

```
func (c *Client) CreateChannelMessage(input CreateChannelMessageInput) (string, error)
```

### SubscribeChannelMessage
- subscribes to a channel messages or message replies, depending on the the id provided

```
func (c *Client) SubscribeChannelMessage(input SubscribeChannelMessageInput) (string, error)
```

### ListChannels
- on connected relays

```
func (c *Client) ListChannels() ([]nostr.RelayChannel, error)
```


### GetChannelMessages
- returns channel messages

```
func (c *Client) GetChannelMessages(input FetchChannelMessageInput) ([]nostr.RelayChannelMessage, error)
```
