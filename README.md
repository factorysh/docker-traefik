traefik for devs pre-configured for docker
============================================

Usage:

Add this to your compose file:

```yaml
---
version: "3"

services:
    traefik:
        image: bearstech/traefik-dev:latest
        volumes:
            - /var/run/docker.sock:/var/run/docker.sock
        ports:
            - "${TRAEFIK_UI_PORT:-8080}:8080"
            - "${TRAEFIK_HTTP_PORT:-80}:80"
        environment:
            MYSQL_ROOT_PASSWORD: ${MYSQL_PASSWORD:-null}
            POSTGRES_USER: ${POSTGRES_USER:-null}
        labels:
            traefik.frontend.rule: Host:traefik.local
            traefik.port: "8080"
            traefik.enable: 'true'
            traefik.tags: web

    app:
        image: yourapp
        expose:
            - 8000
        labels:
            traefik.frontend.rule: Host:app.local
            traefik.enable: 'true'
            traefik.tags: web
```

Add this to your `/etc/hosts` file:

```
127.0.2.1	traefik.local app.local
```

Then use this command to wait for services:

```bash
$ docker-compose exec -T traefik wait_for_services --timeout 20
```

You should be able to see your application at `http://app.local`
