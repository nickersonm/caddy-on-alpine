# nickersonm.com Caddyfile definition
#   (c) Michael Nickerson 2022

www.nickersonm.com {
  # Remove www
  redir https://nickersonm.com{uri} permanent
}
nickersonm.com {
  import subredir
  
  # Import rewrite rules for this host
  import ../rewrite/nickersonm.com
  
  # HTTP auth
  import auth /secure secure
  
  # Typical static site
  import static nickersonm.com
  
  # Enable indexing for specific subdirectories
  file_server /legacy* browse
  file_server /smac* browse
  
  # PHP site
  @phpdirs {
    path *  # Process any PHP by default
    # Except paths listed below
    not path */static/*
    import notrootmatch /static/
  }
  php_fastcgi @phpdirs unix//run/php-fpm8/www.sock
}

# Define explicitly to manage certificates for mail.nickersonm.com
# Certificates in /var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/
mail.nickersonm.com {
  redir https://nickersonm.com permanent
}

# Handle undefined nickersonm.com subdomains
*.nickersonm.com {
  # Map subdomain ({labels.2}) to location; optionally redirect instead
  map {labels.2}      {redir} {location} {
      webmail         "0"     "/webmail"
      resume          "1"     "/resume"
      
      # Default via capture group
      ~(.*)           "0"     "/subdomains/${0}"
  }
  
  # Redirect if desired
  @redir expression `int({redir}) > 0`
  handle @redir {
    redir https://{labels.1}.{labels.0}{location}{uri} permanent
  }
  
  # HTTP auth for any rewrite location
  import auth /subdomains/secure secure
  
  # Otherwise just serve specified location
  import static nickersonm.com{location}/
  
  # Enable indexing for specific subdomains
  @browse {
      not {
        not vars_regexp {http.vars.root} (.*subdomains/jila1.*)
        not vars_regexp {http.vars.root} (.*subdomains/papers.*)
      }
  }
  file_server @browse browse
  
  # PHP site
  @phpdirs {
    # expression `{root} == "*"`
    path *  # Process any PHP by default
    # Except paths listed below
    not path */static/*
    import notrootmatch /static/
  }
  php_fastcgi @phpdirs unix//run/php-fpm8/www.sock
}

