FROM drupal:11-apache-trixie

# Keep the Debian packages from the base image patched.
RUN apt-get update \
	&& apt-get -y upgrade \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Erstellt einen Symlink: /var/www/html/drupal -> /var/www/html
# Dadurch ist Drupal im Container unter / und unter /drupal erreichbar.
RUN ln -s . /var/www/html/drupal

# Nur die notwendigen Proxy-Settings in die default.settings.php schreiben
# (greift bei Neuinstallation; bei bestehendem Volume siehe README:
# Live-settings.php per docker exec nachziehen, Rebuild allein genügt nicht).
# reverse_proxy_trusted_headers ist entscheidend: Caddy terminiert TLS und
# proxyt per HTTP weiter. Ohne vertrautes X-Forwarded-Proto hält sich Drupal
# für http-erreichbar und stellt http://-Redirects aus -> zusammen mit HSTS
# Endlosschleife (ERR_TOO_MANY_REDIRECTS).
RUN echo " \n\
\$settings['reverse_proxy'] = TRUE; \n\
\$settings['reverse_proxy_addresses'] = ['172.21.0.0/16']; \n\
\$settings['reverse_proxy_trusted_headers'] = \\Symfony\\Component\\HttpFoundation\\Request::HEADER_X_FORWARDED_FOR | \\Symfony\\Component\\HttpFoundation\\Request::HEADER_X_FORWARDED_HOST | \\Symfony\\Component\\HttpFoundation\\Request::HEADER_X_FORWARDED_PORT | \\Symfony\\Component\\HttpFoundation\\Request::HEADER_X_FORWARDED_PROTO; \n\
\$settings['trusted_host_patterns'] = ['^mphion\.de$', '^www\.mphion\.de$', '^localhost$']; \n\
" >> /var/www/html/sites/default/default.settings.php