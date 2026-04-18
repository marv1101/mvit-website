FROM drupal:10-apache

# 1. RewriteBase in der .htaccess aktivieren
RUN sed -i 's/# RewriteBase \//RewriteBase \/drupal/' /var/www/html/.htaccess

# 2. Den Code für die settings.php vorbereiten
# Wir nutzen hier eine robustere Methode, um die Pfade zu korrigieren
RUN echo " \n\
// --- Reverse Proxy & Subpath Fix --- \n\
\$settings['reverse_proxy'] = TRUE; \n\
\$settings['reverse_proxy_addresses'] = [\$_SERVER['REMOTE_ADDR']]; \n\
\n\
if (isset(\$_SERVER['HTTP_X_FORWARDED_PREFIX'])) { \n\
    // Das hier zwingt Drupal, den Unterordner in alle URLs einzubauen \n\
    \$GLOBALS['base_path'] = '/drupal/'; \n\
    \$GLOBALS['base_url'] = 'https://' . \$_SERVER['HTTP_HOST'] . '/drupal'; \n\
    \$_SERVER['SCRIPT_NAME'] = '/drupal/index.php'; \n\
    \$_SERVER['REQUEST_URI'] = '/drupal' . \$_SERVER['REQUEST_URI']; \n\
} \n\
" >> /var/www/html/sites/default/default.settings.php