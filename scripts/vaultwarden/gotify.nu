def "main failure_message" [] {
    http post --headers { X-Gotify-Key: $env.GOTIFY_TOKEN } --content-type application/json http://gotify/message { 
      title: "Vaultwarden Backup Failure",
      message: "Vaultwarden backup failed"
    }
}

def "main incomplete_message" [] {
    http post --headers { X-Gotify-Key: $env.GOTIFY_TOKEN } --content-type application/json http://gotify/message { 
      title: "Vaultwarden Backup Incomplete",
      message: "Vaultwarden backup incomplete"
    }
}

def "main success_message" [] {
  http post --headers { X-Gotify-Key: $env.GOTIFY_TOKEN } --content-type application/json http://gotify/message {
    title: "Vaultwarden Backup Success",
    message: "Vaultwarden backup completed successfully",
  }
}

def main [] {}