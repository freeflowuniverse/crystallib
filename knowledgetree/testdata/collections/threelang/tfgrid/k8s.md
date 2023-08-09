# Kubernetes actions

- To deploy a kubernetes cluster, use the kubernetes actions

## Create Operation

- action name: !!tfgrid.kubernetes.create
- parameters:
  - name [optinoal]
    - name of the cluster, must be unique
  - farm_id [optional]
    - farm id to deploy on, if 0, a random eligible farm will be selected
  - workers [optional]
    - number of cluster workers, must be in the range [1, 252]. defaults to `1`
  - capacity [optional]
    - a string in ['small', 'medium', 'large', 'extra-large'] indicating the capacity of the cluster nodes. defaults to `medium`
    - small: 1 vCPU, 2GB RAM, 10GB SSD
    - medium: 2 vCPU, 4GB RAM, 50GB SSD
    - large: 4 vCPU, 8GB RAM, 240 SSD
    - extra-large: 8vCPU, 16GB RAM, 480GB SSD
  - ssh_key [optional]
    - public ssh key to access the instance in a later stage. defaults to `default`
  - add_wireguard_access
    - if true, adds a wireguard access point to the network
  - add_public_ip_to_master
    - true to add public ipv4 to master
  - add_public_ips_to_workers
    - true to add public ipv4 to workers

- Example:
  
  ```md
  !!tfgrid.sshkeys.new
      name: default
      ssh_key: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCs3qtlU13/hHKLE8KUkyt+yAH7z5IKs6PH63dhkeQBBG+VdxlTg/a+6DEXqc5VVL6etKRpKKKpDVqUFKuWIK1x3sE+Q6qZ/FiPN+cAAQZjMyevkr5nmX/ofZbvGUAQGo7erxypB0Ye6PFZZVlkZUQBs31dcbNXc6CqtwunJIgWOjCMLIl/wkKUAiod7r4O2lPvD7M2bl0Y/oYCA/FnY9+3UdxlBIi146GBeAvm3+Lpik9jQPaimriBJvAeb90SYIcrHtSSe86t2/9NXcjjN8O7Fa/FboindB2wt5vG+j4APOSbvbWgpDpSfIDPeBbqreSdsqhjhyE36xWwr1IqktX+B9ZuGRoIlPWfCHPJSw/AisfFGPeVeZVW3woUdbdm6bdhoRmGDIGAqPu5Iy576iYiZJnuRb+z8yDbtsbU2eMjRCXn1jnV2GjQcwtxViqiAtbFbqX0eQ0ZU8Zsf0IcFnH1W5Tra/yp9598KmipKHBa+AtsdVu2RRNRW6S4T3MO5SU='

  !!tfgrid.kubernetes.create
      name: myk8s
      farm_id: 1
      workers: 4
      capacity: small
      add_public_ip_to_master: yes
  ```

## Get Operation

- action name: !!tfgrid.kubernetes.get
- parameters:
  - name [required]
    - cluster name

- Example:
  
  ```md
  !!tfgrid.kubernetes.get
      name: myk8s
  ```

## Update Operations

### Add Operation

- action_name: !!tfgrid.kubernetes.add
- parameters:
  - name [required]
    - cluster name
  - farm_id [optional]
    - farm id to deploy on, if 0, a random eligible farm will be selected
  - capacity [required]
    - a string in ['small', 'medium', 'large', 'extra-large'] indicating the capacity of the worker. defaults to `medium`
    - small: 1 vCPU, 2GB RAM, 10GB SSD
    - medium: 2 vCPU, 4GB RAM, 50GB SSD
    - large: 4 vCPU, 8GB RAM, 240 SSD
    - extra-large: 8vCPU, 16GB RAM, 480GB SSD
  - add_public_ip
    - true to add public ipv4 to the worker

- Example:
  
  ```md
  !!tfgrid.kubernetes.add
      name: myk8s
      farm_id: 2
      capacity: small
  ```

### Remove Operation

- action_name: !!tfgrid.kubernetes.remove
- parameters:
  - name [required]
    - cluster name
  - worker_name [required]
    - worker name to be removed

- Example:
  
  ```md
  !!tfgrid.kubernetes.remove
      name: myk8s
      worker_name: worker1
  ```

## Delete Operation

- action_name: !!tfgrid.kubernetes.delete
- parameters:
  - name [required]
    - cluster name

- Example:
  
  ```md
  !!tfgrid.kubernetes.delete
      name: myk8s
  ```
