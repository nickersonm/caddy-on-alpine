# nickersondevices.com Caddyfile definition
#   (c) Michael Nickerson 2022

www.nickersondevices.com {
  # Remove www
  redir https://nickersondevices.com{uri} permanent
}
nickersondevices.com {
  import subredir
  
  # Import rewrite rules for this host
  import ../rewrite/nickersondevices.com
  
  # PHP site
  # @phpdirs {
  #   path *  # Process any PHP by default
  #   # Except paths listed below
  #   not path */static/*
  # }
  # php_fastcgi @phpdirs unix//run/php-fpm8/www.sock
  
  import static nickersondevices.com
}
