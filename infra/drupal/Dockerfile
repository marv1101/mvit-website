FROM drupal:10-apache

# Wir nutzen ein Script, um die settings.php anzupassen, 
# falls sie existiert, oder bereiten eine vor.
RUN echo " \n\
// Automatische Reverse-Proxy Konfiguration \n\
\$settings['reverse_proxy'] = TRUE; \n\
\$settings['reverse_proxy_addresses'] = [\$_SERVER['REMOTE_ADDR']]; \n\
\$settings['trusted_host_patterns'] = ['^mphion\.de$', '^localhost$', '^nginx$']; \n\
" >> /var/www/html/sites/default/default.settings.php

RUN echo "if (isset(\$_SERVER['HTTP_X_FORWARDED_PREFIX'])) { \n\
  \$_SERVER['SCRIPT_NAME'] = \$_SERVER['HTTP_X_FORWARDED_PREFIX'] . '/index.php'; \n\
  \$_SERVER['REQUEST_URI'] = \$_SERVER['HTTP_X_FORWARDED_PREFIX'] . \$_SERVER['REQUEST_URI']; \n\
}" >> /var/www/html/sites/default/default.settings.php

# Falls du die Base-URL auch fest verdrahten willst (optional):
RUN echo "\$base_url = 'https://mphion.de/drupal';" >> /var/www/html/sites/default/default.settings.php