to test

```bash
echo 'mypasswd' > /tmp/passwd
rsync -avz --password-file=/tmp/passwd /local/path/ rsync://authorizeduser@yourserver/private
```