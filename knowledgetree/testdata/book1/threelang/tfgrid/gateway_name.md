# Gateway Name Actions

- To deploy a gateway name workload, use the Gateway Name actions

## Create Operation

- action name: !!tfgrid.gateway_name.create
- parameters:
  - name [optional]
    - identifier for the gateway, must be unique
  - node_id [optional]
    - node to deploy the gateway workload on, if 0, a random elibile node will be selected
  - backend [required]
    - the URL that the gateway will pass traffic to.
  - tls_passthrough [optional]
    - true to enable TLS encryption

- Example:
  
  ```md
  !!tfgrid.gateway_name.create 
      name: hamadagateway
      backend: http://1.1.1.1:9000
  ```

## Get Operation

- action name: !!tfgrid.gateway_name.get
- parameters:
  - name [required]
    - name of the gateway instance

- Example:
  
  ```md
  !!tfgrid.gateway_name.get
      name: hamadagateway
  ```

## Update Operations

- Update operations are not allowed on gateway names.

## Delete Operation

- action_name: !!tfgrid.gateway_name.delete
- parameters:
  - name [required]
    - name of the gateway instance

- Example:
  
  ```md
  !!tfgrid.gateway_name.delete
      name: hamadagateway
  ```
  