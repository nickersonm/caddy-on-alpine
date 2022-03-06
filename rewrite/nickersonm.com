# Redirects root to blog
redir / https://nickersondevices.com

# Other redirects
rewrite /resume* "/resume/2022-02-09 - Resume.pdf"
uri replace /misc/ksp/ /ksp/
