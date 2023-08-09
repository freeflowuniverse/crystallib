# Funkwhale action

- To deploy a funkwhale instance, use the funkwhale action.

> Check Funkwhale docs [here](https://manual.grid.tf/weblets/weblets_funkwhale.html)

## Create Operation

- action name: !!tfgrid.funkwhale.create
- parameters:
  - name [optional]
    - identifier for the instance, must be unique
  - farm_id [optional]
    - farm id to deploy on, if 0, a random eligible node on a random farm will be selected
  - capacity [optional]
    - a string in ['small', 'medium', 'large', 'extra-large'] indicating the capacity of the funkwhale instance. defaults to `medium`
    - small: 2 vCPU, 1GB RAM, 50GB SSD
    - medium: 2 vCPU, 2GB RAM, 100GB SSD
    - large: 4 vCPU, 4GB RAM, 250 SSD
    - extra-large: 4vCPU, 8GB RAM, 400GB SSD
  - ssh_key [optional]
    - ssh key name defined by a previous action. defaults to `default`
  - admin_email [required]
    - admin email to access admin dashboard
  - admin_username [optional]
    - admin username to access admin dashboard
  - admin_password [optional]
    - admin password to access admin dashboard

- Example:
  
  ```md
  !!tfgrid.sshkeys.new
      name: my_ssh_key
      ssh_key: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCs3qtlU13/hHKLE8KUkyt+yAH7z5IKs6PH63dhkeQBBG+VdxlTg/a+6DEXqc5VVL6etKRpKKKpDVqUFKuWIK1x3sE+Q6qZ/FiPN+cAAQZjMyevkr5nmX/ofZbvGUAQGo7erxypB0Ye6PFZZVlkZUQBs31dcbNXc6CqtwunJIgWOjCMLIl/wkKUAiod7r4O2lPvD7M2bl0Y/oYCA/FnY9+3UdxlBIi146GBeAvm3+Lpik9jQPaimriBJvAeb90SYIcrHtSSe86t2/9NXcjjN8O7Fa/FboindB2wt5vG+j4APOSbvbWgpDpSfIDPeBbqreSdsqhjhyE36xWwr1IqktX+B9ZuGRoIlPWfCHPJSw/AisfFGPeVeZVW3woUdbdm6bdhoRmGDIGAqPu5Iy576iYiZJnuRb+z8yDbtsbU2eMjRCXn1jnV2GjQcwtxViqiAtbFbqX0eQ0ZU8Zsf0IcFnH1W5Tra/yp9598KmipKHBa+AtsdVu2RRNRW6S4T3MO5SU='

  !!tfgrid.funkwhale.create
      name: funkwhale_instance
      farm_id: 4
      capacity: medium
      ssh_key: my_ssh_key
      admin_email: email@gmail.com
      admin_username: username1
      admin_password: pass1
  ```

## Get Operation

- action name: !!tfgrid.funkwhale.get
- parameters:
  - name [required]
    - name of the funkwhale instance

- Example:
  
  ```md
  !!tfgrid.funkwhale.get
      name: funkwhale_instance
  ```

## Delete Operation

- action_name: !!tfgrid.funkwhale.delete
- parameters:
  - name [required]
    - name of the funkwhale instance

- Example:
  
  ```md
  !!tfgrid.funkwhale.delete
      name: funkwhale_instance
  ```
