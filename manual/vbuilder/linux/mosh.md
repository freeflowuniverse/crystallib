
# Mosh

Mosh is an alternative to SSH which works very well for slow unreliable lines.

## OSX

to install to a node do the following

make sure brew is installed

```bash
export SERVER='146.185.93.45'
brew install mosh
ssh root@$SERVER apt update
ssh root@$SERVER apt install mosh -y
ssh root@$SERVER locale-gen
# ssh root@$SERVER locale-gen en_US.UTF-8
```

> more info see https://mosh.org/


## limitations

- cannot forward ssh-key