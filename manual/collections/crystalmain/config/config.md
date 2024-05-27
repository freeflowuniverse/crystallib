

## Configuration (OUTDATED)

All configuration is stored in ~/hero/config as heroscripts.

See examples below what is understood, when loading (configuring) e.g. 3clone it will load these S3 configuration actions.

- [S3](s3.md)

## how to copy to local machine

```bash
export server="root@195.192.213.3"
#export server="195.192.213.3"
rsync -avz -e ssh $server:~/hero/config/ ~/hero/config/
```

## how to copy to remote machine

```bash
export server="root@195.192.213.3"
#export server="195.192.213.3"
rsync -avz -e ssh ~/hero/config/ $server:~/hero/config/ 
```