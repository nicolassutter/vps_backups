let BACKUP_DIR = "/userdata/vaultwarden" # directory that is actually backed up by backrest, this is inside the backrest container
let TIMESTAMP = $(date +'%Y%m%d_%H%M%S')
let SQLITE_BACKUP_NAME = "vw_backup_$TIMESTAMP.sql.gz"
let VW_DIR = "/home/nicolas/dockge/stacks/vaultwarden/data" # directory on the host system where vw data is stored
let VW_DB = "db.sqlite3" # name of the SQLite database file
let TAR_NAME = "vaultwarden_files_$TIMESTAMP.tar.gz"

# Ensure backup directory exists
mkdir -p $BACKUP_DIR

# Clean up old backups
rm -f $"$BACKUP_DIR/*"

# backup the SQLite database
docker run --rm -v $"$VW_DIR:/data:ro" keinos/sqlite3 sqlite3 $"/data/$VW_DB" '.dump' | gzip $in | save $"$BACKUP_DIR/$SQLITE_BACKUP_NAME"

# save existing files to an archive
['config.json' 'attachments' 'rsa_key.pem']
| where { |x| path exists }
| str join ' '
| tar -cz
| save $"$BACKUP_DIR/$TAR_NAME"