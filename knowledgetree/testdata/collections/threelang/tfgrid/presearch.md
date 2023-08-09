# Presearch actions

- To deploy a presearch instance, use the Presearch actions.

> Check Presearch docs [here](https://manual.grid.tf/weblets/weblets_presearch.html)

## Create Operation

- action name: !!tfgrid.presearch.create
- parameters:
  - name [optional]
    - identifier for the instance, must be unique
  - farm_id [optional]
    - farm id to deploy on, if 0, a random eligible node on a random farm will be selected
  - disk_size [optional]
    - size of disk to mount on instance.
  - ssh_key [optional]
    - ssh key name defined by a previous action. defaults to `default`
  - public_ipv4 [optional]
    - if true, a public ipv4 will be added to the instance
  - public_ipv6 [optional]
    - if true, a public ipv6 will be added to the instance
  - registration_code [required]
    - You need to sign up on Presearch in order to get your Presearch Registration Code.
  - public_restore_key [optional]
  - private_resotre_key [optional]
    - presearch config for restoring old nodes
    - to restore old nodes, you need to provide both resotre keys

- Example:
  
  ```md
  !!tfgrid.sshkeys.new
      name: default
      ssh_key: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCs3qtlU13/hHKLE8KUkyt+yAH7z5IKs6PH63dhkeQBBG+VdxlTg/a+6DEXqc5VVL6etKRpKKKpDVqUFKuWIK1x3sE+Q6qZ/FiPN+cAAQZjMyevkr5nmX/ofZbvGUAQGo7erxypB0Ye6PFZZVlkZUQBs31dcbNXc6CqtwunJIgWOjCMLIl/wkKUAiod7r4O2lPvD7M2bl0Y/oYCA/FnY9+3UdxlBIi146GBeAvm3+Lpik9jQPaimriBJvAeb90SYIcrHtSSe86t2/9NXcjjN8O7Fa/FboindB2wt5vG+j4APOSbvbWgpDpSfIDPeBbqreSdsqhjhyE36xWwr1IqktX+B9ZuGRoIlPWfCHPJSw/AisfFGPeVeZVW3woUdbdm6bdhoRmGDIGAqPu5Iy576iYiZJnuRb+z8yDbtsbU2eMjRCXn1jnV2GjQcwtxViqiAtbFbqX0eQ0ZU8Zsf0IcFnH1W5Tra/yp9598KmipKHBa+AtsdVu2RRNRW6S4T3MO5SU='

  !!tfgrid.presearch.create
      name: mypresearch
      farm_id: 3
      disk_size: 10GB
      public_ip: yes
      registration_code: qoweifjquoiwenwfiqurnviqeru9123f234f
  ```

## Get Operation

- action name: !!tfgrid.presearch.get
- parameters:
  - name [required]
    - presearch instance name

- Example:
  
  ```md
  !!tfgrid.presearch.get
      name: mypresearch
  ```

## Update Operations

- Update operations are not allowed on presearch instances.
  
## Delete Operation

- action_name: !!tfgrid.presearch.delete
- parameters:
  - name [required]
    - presearch instance name

- Example:
  
  ```md
  !!tfgrid.presearch.delete
      name: mypresearch
  ```
