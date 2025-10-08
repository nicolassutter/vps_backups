def "main failure_message" [] {
    http post --headers { X-Gotify-Key: $env.GOTIFY_TOKEN } --content-type application/json http://gotify/message { 
      title: "Portfolio Backup Failure",
      message: "Portfolio backup failed"
    }
}

def "main incomplete_message" [] {
    http post --headers { X-Gotify-Key: $env.GOTIFY_TOKEN } --content-type application/json http://gotify/message { 
      title: "Portfolio Backup Incomplete",
      message: "Portfolio backup incomplete"
    }
}

def "main success_message" [] {
  http post --headers { X-Gotify-Key: $env.GOTIFY_TOKEN } --content-type application/json http://gotify/message {
    title: "Portfolio Backup Success",
    message: "Portfolio backup completed successfully",
  }
}

def main [] {}