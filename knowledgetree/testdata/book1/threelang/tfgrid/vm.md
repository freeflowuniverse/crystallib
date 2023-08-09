# Machines Actions

- To deploy a number of virtual machines on the same network, use the machines actions.

## Create Operation

- action name: !!tfgrid.machine.create
- parameters:
  - name [optional]
    - This is the vm's name. If multiple vms are to be deployed, index is appended to the vm's name. If not provided, a random name is generated.
  - network [optional]
    - Identifier for the network that these VMs will be a part of
  - farm_id [optional]
    - farm id to deploy on, if 0, a random eligible node on a random farm will be selectedmultiple farms.
  - times [optional]
    - indicates how many vms will be deployed with the configuration defined by this object. defaults to `1`
    - a number in the range [1, 252]
  - capacity [required]
    - a string in ['small', 'medium', 'large', 'extra-large'] indicating the capacity of the machines. defaults to `medium`
    - small: 1 vCPU, 2GB RAM, 10GB SSD
    - medium: 2 vCPU, 4GB RAM, 50GB SSD
    - large: 4 vCPU, 8GB RAM, 240 SSD
    - extra-large: 8vCPU, 16GB RAM, 480GB SSD
  - disk_size [optional]
    - disk size to mount on vms.
  - ssh_key [optional]
    - the name of the ssh key defined with an sshkeys action. defaults to `default`
  - add_wireguard_access [optional]
    - if true, a wireguard access point will be added to the network
  - add_public_ipv4 [optional]
    - if true, a public ipv4 will be added to each vm
  - gateway [optional]
    - if true, a gateway will deployed for each vm. vms should listen for traffic coming from the gateway at port 9000
  - add_public_ipv6 [optional]
    - if true, a public ipv6 will be added to each vm

- Example:
  
  ```md
  !!tfgrid.sshkeys.new
      name: my_ssh_key
      ssh_key: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCs3qtlU13/hHKLE8KUkyt+yAH7z5IKs6PH63dhkeQBBG+VdxlTg/a+6DEXqc5VVL6etKRpKKKpDVqUFKuWIK1x3sE+Q6qZ/FiPN+cAAQZjMyevkr5nmX/ofZbvGUAQGo7erxypB0Ye6PFZZVlkZUQBs31dcbNXc6CqtwunJIgWOjCMLIl/wkKUAiod7r4O2lPvD7M2bl0Y/oYCA/FnY9+3UdxlBIi146GBeAvm3+Lpik9jQPaimriBJvAeb90SYIcrHtSSe86t2/9NXcjjN8O7Fa/FboindB2wt5vG+j4APOSbvbWgpDpSfIDPeBbqreSdsqhjhyE36xWwr1IqktX+B9ZuGRoIlPWfCHPJSw/AisfFGPeVeZVW3woUdbdm6bdhoRmGDIGAqPu5Iy576iYiZJnuRb+z8yDbtsbU2eMjRCXn1jnV2GjQcwtxViqiAtbFbqX0eQ0ZU8Zsf0IcFnH1W5Tra/yp9598KmipKHBa+AtsdVu2RRNRW6S4T3MO5SU='
  
  !!tfgrid.machine.create
      network: skynet
      sshkey: my_ssh_key
      capacity: small
      times: 2
      gateway: yes
      add_wireguard_access: yes
      disk_size: 10GB
  ```

## Get Operation

- action name: !!tfgrid.machine.get
- parameters:
  - network [required]
    - network name

- Example:
  
  ```md
  !!tfgrid.machine.get
      name: skynet
  ```

## Update Operations

### Add Operation

- to add a number of vms to a previously deployed network, use the Create operation above.

### Remove Operation

- action_name: !!tfgrid.machine.remove
- parameters:
  - network [required]
    - network name
  - machine [required]
    - machine name to be removed

- Example:
  
  ```md
  !!tfgrid.machine.remove
      network: skynet
      machine_name: vm1
  ```

## Delete Operation

- action_name: !!tfgrid.machine.delete
- parameters:
  - network [required]
    - network name

- Example:
  
  ```md
  !!tfgrid.machine.delete
      network: skynet
  ```
