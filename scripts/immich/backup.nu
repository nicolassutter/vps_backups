def "main failure_message" [] {
    http post --headers { X-Gotify-Key: $env.GOTIFY_TOKEN } --content-type application/json $env.GOTIFY_URL { 
      title: "Immich Backup Failure",
      message: "Immich backup failed"
    }
}

def "main incomplete_message" [] {
    http post --headers { X-Gotify-Key: $env.GOTIFY_TOKEN } --content-type application/json $env.GOTIFY_URL { 
      title: "Immich Backup Incomplete",
      message: "Immich backup incomplete"
    }
}

def "main success_message" [] {
  http post --headers { X-Gotify-Key: $env.GOTIFY_TOKEN } --content-type application/json $env.GOTIFY_URL {
    title: "Immich Backup Success",
    message: "Immich backup completed successfully",
  }
}

def "main backup" [] {
  let timestamp = (date now | format date "%Y%m%d_%H%M%S")
  let immich_db_dump_name = $"immich_db_backup_($timestamp).sql.gz"
  let immich_dump = $"/userdata/immich/db_dumps/($immich_db_dump_name)" # inside the container
  docker exec -t -e $"PGPASSWORD=($env.IMMICH_DB_PASS)" immich_postgres pg_dumpall --clean --if-exists $"--username=($env.IMMICH_DB_USER)" | gzip | save $immich_dump
}

def main [] {}