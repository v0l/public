## Build
```bash
go get -v github.com/0xb10c/memo github.com/gin-contrib/cors github.com/gin-contrib/gzip github.com/gin-gonic/gin github.com/json-iterator/go
```

```bash
 go build github.com/0xb10c/memo/api
```

```bash
go build github.com/0xb10c/memo/memod
```

## Link
```bash
ln -s ~/go/bin/memod /usr/sbin/memod
ln -s ~/go/bin/api /usr/sbin/memoapi
```

## Copy configs
```bash
mkdir -p /etc/memo/api
mkdir -p /etc/memo/memod

cp ~/go/src/github.com/0xb10c/memo/api/config.example.toml /etc/memo/api/config.toml
cp ~/go/src/github.com/0xb10c/memo/memod/config.example.toml /etc/memo/memod/config.toml
```

## Edit configs

Edit `memoapi/config.toml`
```toml
[redis]
host = "127.0.0.1"
port = "6379"
```

Edit `memod/config.toml`

## Setup with systemd

```bash
cp ~/go/src/github.com/0xb10c/memo/api/memo-api.service /etc/systemd/system/memoapi.service
cp ~/go/src/github.com/0xb10c/memo/memod/memod.service /etc/systemd/system/memod.service
```

Adjust paths
```
ExecStart=/usr/sbin/memod
WorkingDirectory=/etc/memo/memod/
```
```
ExecStart=/usr/sbin/memoapi
WorkingDirectory=/etc/memo/api/
```

Start services
```
systemctl daemon-reload
systemctl enable --now memod
systemctl enable --now memoapi
```

## Setup website

Copy files to web dir
```bash
cp -R ~/go/src/github.com/0xb10c/memo/www /usr/share/nginx/www/memo
```

Add nginx config
```
upstream mempool.observer {
        server localhost:23485;
}

server {
        listen 80;
        server_name memo.noinput.xyz;
        root /usr/share/nginx/www/memo;

        location / {
                try_files $uri $uri/ /index.html =404;
        }

        location /api {
                proxy_set_header Host $http_host;
                proxy_set_header X-Forwarded-Proto $proxy_x_forwarded_proto;
                proxy_pass http://mempool.observer;
        }
}
```

Test config
``` 
nginx -t
```

Reload config
```
nginx -s reload
```