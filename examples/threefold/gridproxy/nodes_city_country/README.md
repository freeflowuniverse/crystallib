## script examples


### - Get nodes by country or city

This script is used to get the nodes by country or city or even both

#### Args

This script to get nodes by city or country or both

```bash
  --help        get information about the command

  --city 	      name of the city  (optional)

  --country 	  name of the country (optional)

  --network     one of (dev, test, qa, main)  (optional)(default to `test`)
		
  --max-count   maximum number of nodes to be selected (optional)(default to 0 which means no limit)
	
  --cache       enable cache (optional)(default to false)
```

##### You have to specify at least a city or country

- Execute
  - Use country only
    ```bash
    v run examples/get_nodes_by_city_country.v   --country Albania
    ```
  - Use city only
    ```bash
    v run examples/get_nodes_by_city_country.v --city  Douzy
    ```
  - Use both city and country
    ```bash
    v run examples/get_nodes_by_city_country.v --country Albania --city Douzy
    ```
- Help `--help`

  ```bash
  v run examples/get_nodes_by_city_country.v --help
  ```

  ```
  This script to get nodes by city or country or both

    --city 	name of the city  (optional)

    --country 	name of the country (optional)
    
    --network     one of (dev, test, qa, main)  (optional)(default to `test`)
		
    --max-count   maximum number of nodes to be selected (optional)(default to 0 which means no limit)
	
    --cache       enable cache (optional)(default to false)

  ```

  ### - Get nodes by capacity

  This script is used to get the nodes by available resources
  including ssd resource unit `sru`, hd resource unit `hru` and memory resource unit `mru`, ip resource unit `ips`

  #### Args

  This script to get nodes by available resources (sru, hru, mru, ips)

  ```bash
  --help          get   information about   the command

  --sru 		nodes   selected should   have a minumum  value of free sru in GB (ssd  resource unit)   equal to this   (optional)

  --hru 		nodes   selected should   have a minumum  value of free in GB (hd   resource unit)  equal to this    (optional)

  --mru   	nodes   selected should   have a minumum  value of free mru in GB   (memory resource  unit) equal to this  (optional)

  --ips 		nodes   selected should   have a minumum  value of free ips (ip address   resource unit)  equal to this    (optional)

  --network     one of (dev, test, qa, main)  (optional)(default to `test`)
		
  --max-count   maximum number of nodes to be selected (optional)(default to 0 which means no limit)
	
  --cache       enable cache (optional)(default to false)
  ```

- Execute

  - Use (sru, hru, mru, ips)

    ```bash
    v run examples/get_nodes_by_capacity.v --sru 500 --ips 5 --hru 500 --mru 50
    ```

  - Use single argument
    ```bash
    v run examples/get_nodes_by_capacity.v --sru 500
    ```
  - Use no arguments in this case will list all the nodes

    ```bash
    v run examples/get_nodes_by_capacity.v
    ```

  - Help `--help`

    ```bash
    This script to get nodes by available resources

    --sru 		nodes selected should have a minumum value of free sru in GB (ssd resource unit) equal to this  (optional)

    --hru 		nodes selected should have a minumum value of free hru in GB (hd resource unit) equal to this  (optional)

    --mru   	nodes selected should have a minumum value of free mru in GB (memory resource unit) equal to this (optional)

    --ips 		nodes selected should have a minumum value of ips (core resource unit) equal to this  (optional)

    --network     one of (dev, test, qa, main)  (optional)(default to `test`)
		
    --max-count   maximum number of nodes to be selected (optional)(default to 0 which means no limit)
	
    --cache       enable cache (optional)(default to false)
    ```
