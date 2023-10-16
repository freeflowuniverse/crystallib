# SFTPGO

## API Key Generation

This example shows how to run sftpgo sal example generate api key

To run the api key generation example

- `-a`: address, address of sftpgo api like http://localhost:8080/api/v2
- `-j`: jwt from sftpgo server generate it from http://localhost:8080/api/v2/token
- `-n`: key name
- `-c`: key description
- `-d`: admin username
- `-u`: normal user username
  note: you can not pass -d and -u at the same time, key must relate to a user or admin not both at the same time

```sh
v -cg run main_api_key.v -a <ADDRESS> -j <JWT>  -n <KEY_NAME> -c <DESCRIPTION> -d <ADMIN>
```

or

```sh
v -cg run main_api_key.v -a <ADDRESS> -j <JWT>  -n <KEY_NAME> -c <DESCRIPTION> -u <USER>
```
