export IMMICH_DB_DUMP_NAME="immich_db_backup_$(date +%Y%m%d_%H%M%S).sql.gz"
export IMMICH_DUMP="/userdata/immich/db_dumps/$IMMICH_DB_DUMP_NAME"
docker exec -t -e PGPASSWORD=$IMMICH_DB_PASS immich_postgres pg_dumpall --clean --if-exists --username=$IMMICH_DB_USER | gzip > $IMMICH_DUMP
        
