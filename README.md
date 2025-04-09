Lightweight WordPress container with Nginx & PHP-FPM 8.2 based on Alpine Linux.

Uses MariaDB 11 and Valkey 8, both connected via unix sockets. Cache is set up automatically with W3 Total Cache if using the default `docker-compose.yml` file.

This is meant to be easy to deploy with Coolify (using Caddy proxy) and uses Coolify's automatically generated env vars to configure credentials. However it can be modified to run without Coolify.

- May use existing wordpress files (installs fresh copy if no files found)
- Healthcheck runs wp-cron (disabled automatically in wp-config.php)
- Allows cron commands to be specified
- Allows installation of user specified plugins at run time
- Auto database import on first run if db is empty and sql file exists in `/usr/src/wordpress/`
- Uses [VIPS Image Editor](https://github.com/henrygd/vips-image-editor) for better image processing (libvips is baked into the image)

## Usage

See [docker-compose.yml](docker-compose.yml).

If you don't mount existing wordpress files, it will install a fresh copy automatically. This may take a second so don't worry if you get a 502 error. After setup, restart the container to update wp-config and install plugins.

By default it uses a self-signed SSL certificate. We don't need a letsencrypt cert if proxying through Cloudflare on strict mode. If not proxying through Cloudflare, remove the `caddy_0.tls` label to use a letsencrypt cert.

### WP-CLI

This image includes [wp-cli](https://wp-cli.org/) which can be used like this:

    docker exec <your container name> /usr/local/bin/wp --path=/usr/src/wordpress <your command>
