# Taiga action

- To deploy a taiga instance, use the Taiga action.

> Check Taiga docs [here](https://manual.grid.tf/weblets/weblets_taiga.html)

## Create Operation

- action name: !!tfgrid.taiga.create
- parameters:
  - name [optional]
    - identifier for the instance, must be unique
  - farm_id [optional]
    - farm id to deploy on, if 0, a random eligible node on a random farm will be selected
  - capacity [optional]
    - a string in ['small', 'medium', 'large', 'extra-large'] indicating the capacity of the taiga instance. defaults to `medium`
    - small: 2 vCPU, 2GB RAM, 100GB SSD
    - medium: 2 vCPU, 4GB RAM, 150GB SSD
    - large: 4 vCPU, 4GB RAM, 250 SSD
    - extra-large: 4vCPU, 8GB RAM, 400GB SSD
  - disk_size [optional]
    - size of disk to mount on instance. defaults to `50`
  - ssh_key [required]
    - ssh key name defined by a previous action. defaults to `default`
  - public_ipv6
    - if true, a public ipv6 will be added to the instance
  - admin_username [required]
  - admin_password [required]
  - admin_email [required]

- Example:
  
  ```md
  !!tfgrid.sshkeys.new
      name: my_ssh_key
      ssh_key: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCs3qtlU13/hHKLE8KUkyt+yAH7z5IKs6PH63dhkeQBBG+VdxlTg/a+6DEXqc5VVL6etKRpKKKpDVqUFKuWIK1x3sE+Q6qZ/FiPN+cAAQZjMyevkr5nmX/ofZbvGUAQGo7erxypB0Ye6PFZZVlkZUQBs31dcbNXc6CqtwunJIgWOjCMLIl/wkKUAiod7r4O2lPvD7M2bl0Y/oYCA/FnY9+3UdxlBIi146GBeAvm3+Lpik9jQPaimriBJvAeb90SYIcrHtSSe86t2/9NXcjjN8O7Fa/FboindB2wt5vG+j4APOSbvbWgpDpSfIDPeBbqreSdsqhjhyE36xWwr1IqktX+B9ZuGRoIlPWfCHPJSw/AisfFGPeVeZVW3woUdbdm6bdhoRmGDIGAqPu5Iy576iYiZJnuRb+z8yDbtsbU2eMjRCXn1jnV2GjQcwtxViqiAtbFbqX0eQ0ZU8Zsf0IcFnH1W5Tra/yp9598KmipKHBa+AtsdVu2RRNRW6S4T3MO5SU='

  !!tfgrid.taiga.create
      name: hamadataiga
      capacity: medium
      size: 50GB
      ssh_key: my_ssh_key
      admin_username: user1
      admin_password: pass1
      admin_email: email@gmail.com
  ```

## Get Operation

- action name: !!tfgrid.taiga.get
- parameters:
  - name [required]
    - name of the taiga instance

- Example:
  
  ```md
  !!tfgrid.taiga.get
      name: hamadataiga
  ```

## Update Operations

- Update operations are not allowed on taiga instances.
  
## Delete Operation

- action_name: !!tfgrid.taiga.delete
- parameters:
  - name [required]
    - name of the taiga instance

- Example:
  
  ```md
  !!tfgrid.taiga.delete
      name: hamadataiga
  ```
