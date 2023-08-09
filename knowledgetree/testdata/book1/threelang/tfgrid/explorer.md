# Explorer action

- To retrieve information about the tfgrid, use the explorer action

## Nodes Operation

- Query and filter nodes on the chain.

- action name: !!tfgrid.nodes.get
- parameters:
  - `network`: chain network to query. one of (`main`, `test`, `qa`, `dev`). defaults to `main`.
  - `status`: node status (`up`, `down`)
  - `free_mru`: free memory
  - `free_hru`: free HDD space
  - `free_sru`: free SSD space
  - `total_mru`: total memory
  - `total_hru`: total HDD space
  - `total_sru`: total SSD space
  - `total_cru`: total CPU cores
  - `country`: country where the node is located
  - `country_contains`: substring of country where the node is located
  - `city`: city where the node is located
  - `city_contains`: substring of city where the node is located
  - `farm_name`: full farm name (case-sensitive)
  - `farm_name_contains`: substring of farm name (case-insensitive)
  - `farm_id`: farm id where the node is registered
  - `free_ips`: number of free IPs
  - `gateway`: true if the node is a gateway
  - `dedicated`: true if the node farm is dedicated
  - `rentable`: true if the node is available for rent
  - `rented`: true if the node is rented
  - `rented_by`: twin id for the twin that rented the node
  - `available_for`: twin id for the twin that can use the node to deploy on
  - `node_id`: node id
  - `twin_id`: twin id for the node

  - `size`: size of the returned batch of the nodes. default is 50
  - `page`: offset of the returned batch of the nodes. default is 1
  - `randomize`: if true, the returned batch of nodes will be random. default is false
  - `count`: if true, will return the number of nodes that match the filter even if the size is set. default is false.

- Examples:
  - get specific node by it's id
  
    ```md
    !!tfgrid.nodes.get
        node_id: 11
    ```

  - get all nodes that has public access

      ```md
      !!tfgrid.nodes.get
          gateway: true
      ```

  - filter nodes based on capacity
  
      ```md
      !!tfgrid.nodes.get
          free_mru: 2GB
          free_hru: 100GB
          free_sru: 50GB
      ```

## Node Operation

- Get a specif node information by providing its id.

- action name: !!tfgrid.explorer.node
- paramters:
  - `network`: chain network to query. one of (`main`, `test`, `qa`, `dev`). defaults to `main`.
  - `node_id`: node id

- example:
  
    ```md
    !!tfgrid.nodes.get
        node_id: 11
    ```

## Node Status Operation

- Get node status by providing its id.

- action name: !!tfgrid.explorer.node_status
- paramters:
  - `network`: chain network to query. one of (`main`, `test`, `qa`, `dev`). defaults to `main`.
  - `node_id`: node id

- example:
  
    ```md
    !!tfgrid.explorer.node_status
        node_id: 11
    ```

## Contracts Operation

- Query and filter contracts on the chain.

- action name: !!tfgrid.contracts.get
- parameters:
  - `network`: chain network to query. one of (`main`, `test`, `qa`, `dev`). defaults to `main`.
  - `contract_id`: contract id
  - `twin_id`: twin id of the contract creator
  - `node_id`: node id of the contract
  - `type`: type of the contract
  - `state`: state of the contract
  - `name`: contract name
  - `number_of_public_ips`: number of public ips in the contract
  - `deployment_data`: deployment metadata
  - `deployment_hash`: deployment hash

  - `size`: size of the returned batch of the contracts. default is 50
  - `page`: offset of the returned batch of the contracts. default is 1
  - `randomize`: if true, the returned batch of contracts will be random. default is false
  - `count`: if true, will return the number of contracts that match the filter even if the size is set. default is false.

- examples:
  - get specific contract by it's id
  
      ```md
      !!tfgrid.contracts.get
          contract_id: 2014
      ```

  - get all contracts on a node

      ```md
      !!tfgrid.contracts.get
          node_id: 11
      ```

## Statistics Operation

- Get counters from the explorer

- action name: !!tfgrid.stats.get
- paramters:
  - `network`: chain network to query. one of (`main`, `test`, `qa`, `dev`). defaults to `main`.
  - `status`: status of the nodes (`up`, `down`)

- example:
  
    ```md
    !!tfgrid.stats.get
        status: up
    ```

## Farms Operation

- Query and filter farms on the chain.

- action name: !!tfgrid.farms.get
- parameters:
  - `network`: chain network to query. one of (`main`, `test`, `qa`, `dev`). defaults to `main`.
  - `free_ips`: number of free public IPs on the farm
  - `total_ips`: number of total public IPs on the farm
  - `stellar_address`: farm stellar address
  - `pricing_policy_id`: farm pricing policy id
  - `farm_id`: farm id
  - `twin_id`: twin id for the farm
  - `name`: full name of the farm (case-sensitive)
  - `name_contains`: substring of the farm name (case-insensitive)
  - `certification_type`: farm certification type (`DIY`, `Gold`)
  - `dedicated`: true if the farm is dedicated

  - `size`: size of the returned batch of the farms. default is 50
  - `page`: offset of the returned batch of the farms. default is 1
  - `randomize`: if true, the returned batch of farms will be random. default is false
  - `count`: if true, will return the number of farms that match the filter even if the size is set. default is false.

- examples:
  - get specific farm by it's id

      ```md
      !!tfgrid.farms.get
          farm_id: 1
      ```

  - get all farms that marked as dedicated

      ```md
      !!tfgrid.farms.get
          dedicated: true
      ```

  - filter farms based on capacity

      ```md
      !!tfgrid.farms.get
          free_ips: 2
      ```

## Twins Operation

- Query and filter twins on the chain.

- action name: !!tfgrid.twins.get
- parameters:
  - `network`: chain network to query. one of (`main`, `test`, `qa`, `dev`). defaults to `main`.
  - `twin_id`: twin id
  - `account_id`: twin account address
  - `relay`: relay address of the twin
  - `public_key`: twin public key

  - `size`: size of the returned batch of the twins. default is 50
  - `page`: offset of the returned batch of the twins. default is 1
  - `randomize`: if true, the returned batch of twins will be random. default is false
  - `count`: if true, will return the number of twins that match the filter even if the size is set. default is false.

- examples:
  - get specific twin by it's id

      ```md
      !!tfgrid.twins.get
          twin_id: 29
      ```

  - get twin by it's account address

      ```md
      !!tfgrid.twins.get
          account_id:'5FiC58mQ3J8dbfpUwDvSxYAgnW5uibmubJoATMFwkT6tC2Sn'
      ```
