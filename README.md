# VPS backups

Simple Dockerfile that creates an image that has everything I need to backup things on my VPS.

Essentially, it installs python and the `minio` client which I then use to run a script that backups my files to a MinIO instance.

```
docker run --rm \
    -v $(echo $PWD):/app \
    -v /my/backup/dir:/backup_dir \
    ghcr.io/nicolassutter/vps_backups:latest python /app/script.py
```

