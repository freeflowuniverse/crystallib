# Gateway FQDN Actions

- To deploy a gateway fqdn workload, use the Gateway FQDN actions

## Create Operation

- action name: !!tfgrid.gateway_fqdn.create
- parameters:
  - name [optional]
    - identifier for the gateway, must be unique
  - node_id [required]
    - node to deploy the gateway workload on
  - fqdn [required]
    - The fully qualified domain name that points to this gateway
  - backend [required]
    - The backend that the gateway will point to
  - tls_passthrough [optional]
    - true to enable TLS encryption

- Example:
  
  ```md
  !!tfgrid.gateway_fqdn.create
      name: hamadafqdn
      node_id: 11
      backend: http://1.1.1.1:9000
      fqdn: hamada1.3x0.me
  ```

## Get Operation

- action name: !!tfgrid.gateway_fqdn.get
- parameters:
  - name [required]
    - name of the gateway instance

- Example:
  
  ```md
  !!tfgrid.gateway_fqdn.get
      name: hamadafqdn
  ```

## Update Operations

- Update operations are not allowed on gateway fqdn.

## Delete Operation

- action_name: !!tfgrid.gateway_fqdn.delete
- parameters:
  - name [required]
    - name of the gateway instance

- Example:
  
  ```md
  !!tfgrid.gateway_fqdn.delete
      name: hamadafqdn
  ```
