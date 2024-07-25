


nerdctl.lima run -d \
  --name postgresql \
  -e POSTGRES_PASSWORD=1234 \
  -p 5432:5432 \
  -v postgres_data:/var/lib/postgresql/data \
  postgres


nerdctl.lima run --name test -m x86_64 alpine

nerdctl run --platform amd64 -it ubuntu /bin/bash