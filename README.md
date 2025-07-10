example :

```
docker run --rm \
    -v $(echo $PWD):/app \
    -v /my/backup/dir:/backup_dir \
    imageName:tag python /app/script.py
```

