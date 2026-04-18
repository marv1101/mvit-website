FROM drupal:10-apache

# Wir erstellen einen Symlink, damit Apache den Ordner /drupal/ tatsächlich sieht
# /var/www/html/drupal -> zeigt auf /var/www/html
RUN ln -s . /var/www/html/drupal

# Jetzt die Konfiguration für die settings.php (via Autostart-Script oder direkt)
# Wir nutzen hier den 'Request'-Stack von Symfony, um den Pfad sauber zu setzen.
RUN echo " \n\
if (isset(\$_SERVER['HTTP_X_FORWARDED_PREFIX']) && \$_SERVER['HTTP_X_FORWARDED_PREFIX'] == '/drupal') { \n\
    \$settings['reverse_proxy'] = TRUE; \n\
    \$settings['reverse_proxy_addresses'] = [\$_SERVER['REMOTE_ADDR']]; \n\
    \n\
    // Das zwingt Drupal, alle Links mit /drupal zu generieren \n\
    \$GLOBALS['base_path'] = '/drupal/'; \n\
    \$_SERVER['SCRIPT_NAME'] = '/drupal/index.php'; \n\
    \$_SERVER['REQUEST_URI'] = '/drupal' . \$_SERVER['REQUEST_URI']; \n\
} \n\
" >> /var/www/html/sites/default/default.settings.php