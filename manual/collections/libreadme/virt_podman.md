
# buildah tricks

## run something interactive in the buildah

```bash
buildah run --terminal --env TERM=xterm builder /bin/bash
```

