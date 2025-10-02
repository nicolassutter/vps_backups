BACKUP_DIR="/userdata/vaultwarden" # directory that is actually backed up by backrest, this is inside the backrest container
TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
SQLITE_BACKUP_NAME="vw_backup_$TIMESTAMP.sql.gz"
VW_DIR="/var/lib/docker/volumes/o80w4cwooogw0owk8ko4cck0_vw-data/_data" # directory on the host system where vw data is stored
VW_DB="db.sqlite3" # name of the SQLite database file

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Clean up old backups
rm -f "$BACKUP_DIR"/*

# backup the SQLite database
docker run --rm -v "$VW_DIR:/data:ro" keinos/sqlite3 sqlite3 /data/$VW_DB '.dump' | gzip > "$BACKUP_DIR/$SQLITE_BACKUP_NAME"

# copy other necessary files using Alpine container, since Docker has access to host filesystem
# otherwise the /var/lib/docker/volumes path is not accessible from within the backrest container
TAR_NAME="vaultwarden_files_$TIMESTAMP.tar.gz"

# Use separate Bun script to filter files and create tar archive
docker run --rm \
    -v "$VW_DIR:/src:ro" \
    -v "/home/nicolas/dev/vps_backups/scripts:/scripts:ro" \
    oven/bun:alpine \
    sh -c "cd /src && bun run /scripts/vaultwarden/filter-and-tar.js" > "$BACKUP_DIR/$TAR_NAME"