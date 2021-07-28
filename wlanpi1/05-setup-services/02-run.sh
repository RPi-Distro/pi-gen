#!/bin/bash -e

####################
# Install Flask WebUI
####################

# Configure: nginx
# copy_overlay /etc/nginx/nginx.conf -o root -g root -m 644

# Configure: PHP
# copy_overlay /etc/php/7.3/fpm/php.ini -o root -g root -m 644

on_chroot <<CHEOF
	# Installing: WebUI
	# pipx install --include-deps git+https://github.com/wlan-pi/wlanpi-webui@main#egg=wlanpi_webui

	# Remove default config: nginx
	# rm -f /etc/nginx/sites-enabled/default

	# Fix permissions: /var/www
	# chown -R www-data:www-data /var/www
CHEOF
