# VPS backups

Simple Dockerfile that creates an image that has everything I need to backup things on my VPS.

```
volumes:
  vw-data:
services:
  vaultwarden:
    image: 'vaultwarden/server:latest'
    container_name: vaultwarden
    restart: unless-stopped
    volumes:
      - 'vw-data:/data/'

  # this is a dumb container, we need to set a cron job inside the container to use it
  my_backup_solution:
    container_name: my_backup_solution
    image: ghcr.io/nicolassutter/vps_backups:latest
    environment:
      - MINIO_ENDPOINT=
      - MINIO_ACCESS_KEY=
      - MINIO_SECRET_KEY=
      - MINIO_BUCKET_NAME=
    volumes:
      - vw-data:/vw-data:ro
```

