

## set env variables in a session

Example how to use in a caddy file

```js

!!session.env_set key:'JWT_SHARED_KEY' val:'...'

!!session.env_set key:'GOOGLE_CLIENT_SECRET' val:'...'

!!session.env_set key:'GOOGLE_CLIENT_ID' val:'...'

!!caddy.configure
    caddyfile:'Caddyfile'
    restart:true

```

The environmen variables will be set in the current session, we can also specify a sessionname
