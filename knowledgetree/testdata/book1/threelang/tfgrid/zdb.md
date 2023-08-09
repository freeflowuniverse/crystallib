# ZDB Actions

- To deploy a ZDB, use the ZDB actions

## Create Operation

- action name: !!tfgrid.zdbs.create
- parameters:
  - name [optional]
    - zdb name. must be unique
  - node_id [optional]
    - node id to deploy the ZDB on, if 0, a random eligible node will be selected
  - password [optional]
    - zdb password
  - size [required]
    - size of the ZDB in GB. defaults to `10`
  - public [optional]
    - if true, makes it read-only if password is set, writable if no password set. defaults to `false`
  - user_mode
    - Mode of the ZDB, `user` or `seq`. `user` is the default mode where a user can SET their own keys, like any key-value store. All keys are kept in memory. in `seq` mode, keys are sequential and autoincremented. defaults to `user`

- Example:
  
  ```md
  !!tfgrid.zdbs.create 
      name: hamadazdb
      size: 10GB
      password: pass1
  ```

## Get Operation

- action name: !!tfgrid.zdbs.get
- parameters:
  - name [required]
    - zdb name

- Example:
  
  ```md
  !!tfgrid.zdbs.get
      name: hamadazdb
  ```

## Update Operations

- Update operations are not allowed on ZDBs.

## Delete Operation

- action_name: !!tfgrid.zdbs.delete
- parameters:
  - name [required]
    - zdb name

- Example:
  
  ```md
  !!tfgrid.zdbs.delete
      name: hamadazdb
  ```
