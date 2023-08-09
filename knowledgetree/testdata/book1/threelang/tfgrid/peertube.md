# Peertube actions

- To deploy a peertube instance, use the Peertube actions.

> Check Peertube docs [here](https://manual.grid.tf/weblets/weblets_peertube.html)

## Create Operation

- action name: !!tfgrid.peertube.create
- parameters:
  - name [optional]
    - identifier for the instance, must be unique
  - farm_id [optional]
    - farm id to deploy on, if 0, a random eligible farm will be selected
  - capacity [optional]
    - a string in ['small', 'medium', 'large', 'extra-large'] indicating the capacity of the peertube instance. defaults to `medium`
    - small: 1 vCPU, 2GB RAM, 10GB SSD
    - medium: 2 vCPU, 2GB RAM, 100GB SSD
    - large: 4 vCPU, 4GB RAM, 250 SSD
    - extra-large: 4vCPU, 8GB RAM, 400GB SSD
  - ssh_key [optional]
    - ssh key name defined by a previous action. defaults to `default`
  - db_username [optional]
    - database username
  - db_password [optional]
    - database password
  - admin_email [required]
    - admin email

- Example:
  
  ```md
  !!tfgrid.sshkeys.new
      name: my_ssh_key
      ssh_key: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCs3qtlU13/hHKLE8KUkyt+yAH7z5IKs6PH63dhkeQBBG+VdxlTg/a+6DEXqc5VVL6etKRpKKKpDVqUFKuWIK1x3sE+Q6qZ/FiPN+cAAQZjMyevkr5nmX/ofZbvGUAQGo7erxypB0Ye6PFZZVlkZUQBs31dcbNXc6CqtwunJIgWOjCMLIl/wkKUAiod7r4O2lPvD7M2bl0Y/oYCA/FnY9+3UdxlBIi146GBeAvm3+Lpik9jQPaimriBJvAeb90SYIcrHtSSe86t2/9NXcjjN8O7Fa/FboindB2wt5vG+j4APOSbvbWgpDpSfIDPeBbqreSdsqhjhyE36xWwr1IqktX+B9ZuGRoIlPWfCHPJSw/AisfFGPeVeZVW3woUdbdm6bdhoRmGDIGAqPu5Iy576iYiZJnuRb+z8yDbtsbU2eMjRCXn1jnV2GjQcwtxViqiAtbFbqX0eQ0ZU8Zsf0IcFnH1W5Tra/yp9598KmipKHBa+AtsdVu2RRNRW6S4T3MO5SU='
  
  !!tfgrid.peertube.create
      name: mypeertube
      farm_id: 2
      capacity: extra-large
      ssh_key: my_ssh_key
      db_username: dbusername
      db_password: dbpassword
      admin_email: admin@gmail.com
  ```

## Get Operation

- action name: !!tfgrid.peertube.get
- parameters:
  - name [required]
    - name of the peertube instance

- Example:
  
  ```md
  !!tfgrid.peertube.get
      name: mypeertube
  ```

## Update Operations

- Update operations are not allowed on gateway names.
  
## Delete Operation

- action_name: !!tfgrid.peertube.delete
- parameters:
  - name [required]
    - name of the peertube instance

- Example:
  
  ```md
  !!tfgrid.peertube.delete
      name: mypeertube
  ```
