BACKUP_DIR="/userdata/portfolio"
BACKUP_NAME="portfolio_backup_$(date +'%Y%m%d_%H%M%S').sql.gz"
PORTFOLIO_DATA_DIR="/home/nicolas/dockge/stacks/minoro/data" # on the host system

mkdir -p $BACKUP_DIR

# Clean up
rm -f $BACKUP_DIR/portfolio_backup_*.sql.gz

# backup the SQLite database
docker run --rm -v $PORTFOLIO_DATA_DIR:/data keinos/sqlite3 sqlite3 /data/data.db '.dump' | gzip > $BACKUP_DIR/$BACKUP_NAME
