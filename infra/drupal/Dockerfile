FROM drupal:10-apache

# Erstellt einen Symlink: /var/www/html/drupal -> /var/www/html
# Dadurch ist Drupal im Container unter / und unter /drupal erreichbar.
RUN ln -s . /var/www/html/drupal

# Nur die notwendigen Proxy-Settings in die default.settings.php schreiben
RUN echo " \n\
\$settings['reverse_proxy'] = TRUE; \n\
\$settings['reverse_proxy_addresses'] = [\$_SERVER['REMOTE_ADDR']]; \n\
\$settings['trusted_host_patterns'] = ['^mphion\.de$', '^localhost$']; \n\
" >> /var/www/html/sites/default/default.settings.php