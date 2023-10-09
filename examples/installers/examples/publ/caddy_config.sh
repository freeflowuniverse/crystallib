scp root@185.69.166.150:/etc/caddy/Caddyfile /tmp/Caddyfile
code /tmp/Caddyfile
scp /tmp/Caddyfile root@185.69.166.150:/etc/caddy/Caddyfile

caddy validate --config /etc/caddy/Caddyfile

caddy start --config /etc/caddy/Caddyfile

# rsync -rav * root@d.threefold.me:/var/www/777/