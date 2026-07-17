#!/bin/sh
set -eu

cd /var/www/html

if [ ! -f wp-config.php ]; then
	cp wp-config-sample.php wp-config.php
	sed -i "s/database_name_here/${WORDPRESS_DB_NAME:-wpdb}/" wp-config.php
	sed -i "s/username_here/${WORDPRESS_DB_USER:-wpuser}/" wp-config.php
	sed -i "s/password_here/${WORDPRESS_DB_PASSWORD:-supersecret}/" wp-config.php
	sed -i "s/localhost/${WORDPRESS_DB_HOST:-db:3306}/" wp-config.php
fi

chown -R www-data:www-data /var/www/html

exec "$@"
