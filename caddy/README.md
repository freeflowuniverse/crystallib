# Caddy

## Using as a reverse proxy

- In your code in vweb main just spawn it like following

```
fn main() {
        domain := 'ashraf.3x0.me'
        port := 8081
        // start caddy a reverse proxy
        spawn caddy.run_reverse_proxy(domain, port)
        vweb.run_at(new_app(), vweb.RunParams{
                port: port
        }) or { panic(err) }
}


```
