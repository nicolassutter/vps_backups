let backup_dir = "/userdata/vaultwarden" # directory that is actually backed up by backrest, this is inside the backrest container
let timestamp = date now | format date "%Y-%m-%d %H:%M:%S"

let sqlite_backup_name = $"vw_backup_($timestamp).sql.gz"
let tar_name = $"vaultwarden_files_($timestamp).tar.gz"

let vw_dir = "/home/nicolas/dockge/stacks/vaultwarden/data" # directory on the host system where vw data is stored
let vw_db = "db.sqlite3" # name of the SQLite database file

# Ensure backup directory exists
mkdir $backup_dir

# Clean up old backups
rm -f ($"($backup_dir)/*" | into glob)

# backup the SQLite database
docker run --rm -v $"($vw_dir):/data:ro" keinos/sqlite3 sqlite3 $"/data/($vw_db)" '.dump' | gzip | save $"($backup_dir)/($sqlite_backup_name)"

# save existing files to an archive using nushell and docker to have access to host filesystem
docker run --rm -v $"($vw_dir):/src:ro" ghcr.io/nushell/nushell:latest-alpine -c "
cd /src;
let files = ['config.json' 'attachments' 'rsa_key.pem'] | where { |x| path exists };
tar -cz ...$files;
"
| save $"($backup_dir)/($tar_name)"
