#!/bin/sh
set -eu

read_secret() {
	var_name="$1"
	file_var_name="${var_name}_FILE"
	eval value="\${$var_name:-}"
	eval file_value="\${$file_var_name:-}"

	if [ -n "$file_value" ] && [ -f "$file_value" ]; then
		tr -d '\r\n' < "$file_value"
	else
		printf "%s" "$value"
	fi
}

wordpress_db_name="$(read_secret WORDPRESS_DB_NAME)"
wordpress_db_user="$(read_secret WORDPRESS_DB_USER)"
wordpress_db_password="$(read_secret WORDPRESS_DB_PASSWORD)"
wordpress_db_host="$(read_secret WORDPRESS_DB_HOST)"

: "${wordpress_db_name:=wpdb}"
: "${wordpress_db_user:=wpuser}"
: "${wordpress_db_password:=supersecret}"
: "${wordpress_db_host:=db:3306}"

cd /var/www/html

if [ ! -f wp-config.php ]; then
	cp wp-config-sample.php wp-config.php
	sed -i "s/database_name_here/${wordpress_db_name}/" wp-config.php
	sed -i "s/username_here/${wordpress_db_user}/" wp-config.php
	sed -i "s/password_here/${wordpress_db_password}/" wp-config.php
	sed -i "s/localhost/${wordpress_db_host}/" wp-config.php
fi

chown -R www-data:www-data /var/www/html

exec "$@"
