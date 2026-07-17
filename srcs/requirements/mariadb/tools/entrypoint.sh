#!/bin/sh
set -eu

DATADIR="${MYSQL_DATADIR:-/var/lib/mysql}"
RUNDIR="/run/mysqld"
SOCKET="${RUNDIR}/mysqld.sock"

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

mysql_database="$(read_secret MYSQL_DATABASE)"
[ -n "$mysql_database" ] || mysql_database="$(read_secret MARIADB_DATABASE)"
mysql_user="$(read_secret MYSQL_USER)"
[ -n "$mysql_user" ] || mysql_user="$(read_secret MARIADB_USER)"
mysql_password="$(read_secret MYSQL_PASSWORD)"
[ -n "$mysql_password" ] || mysql_password="$(read_secret MARIADB_PASSWORD)"
mysql_root_password="$(read_secret MYSQL_ROOT_PASSWORD)"
[ -n "$mysql_root_password" ] || mysql_root_password="$(read_secret MARIADB_ROOT_PASSWORD)"

sql_escape() {
	printf "%s" "$1" | sed "s/'/''/g"
}

sql_identifier_escape() {
	printf "%s" "$1" | sed 's/`/``/g'
}

mysql_database_sql="$(sql_identifier_escape "$mysql_database")"
mysql_user_sql="$(sql_escape "$mysql_user")"
mysql_password_sql="$(sql_escape "$mysql_password")"
mysql_root_password_sql="$(sql_escape "$mysql_root_password")"

mkdir -p "$DATADIR" "$RUNDIR"
chown -R mysql:mysql "$DATADIR" "$RUNDIR"
chmod 750 "$DATADIR"

if [ ! -d "$DATADIR/mysql" ]; then
	if [ -z "$mysql_root_password" ]; then
		echo "ERROR: MYSQL_ROOT_PASSWORD or MARIADB_ROOT_PASSWORD must be set on first initialization" >&2
		exit 1
	fi
	if [ -n "$mysql_user" ] && [ -z "$mysql_password" ]; then
		echo "ERROR: MYSQL_PASSWORD or MARIADB_PASSWORD must be set when MYSQL_USER/MARIADB_USER is set" >&2
		exit 1
	fi

	echo "Initializing MariaDB data directory in ${DATADIR}"
	mariadb-install-db \
		--user=mysql \
		--datadir="$DATADIR" \
		--auth-root-authentication-method=normal \
		--skip-test-db >/dev/null

	echo "Starting temporary MariaDB server for bootstrap"
	mariadbd \
		--user=mysql \
		--datadir="$DATADIR" \
		--socket="$SOCKET" \
		--pid-file="${RUNDIR}/bootstrap.pid" \
		--skip-networking &
	pid="$!"

	for i in $(seq 1 60); do
		if mariadb-admin --socket="$SOCKET" ping --silent >/dev/null 2>&1; then
			break
		fi
		if ! kill -0 "$pid" >/dev/null 2>&1; then
			echo "ERROR: temporary MariaDB server exited during bootstrap" >&2
			exit 1
		fi
		sleep 1
	done

	if ! mariadb-admin --socket="$SOCKET" ping --silent >/dev/null 2>&1; then
		echo "ERROR: temporary MariaDB server did not become ready" >&2
		kill "$pid" >/dev/null 2>&1 || true
		exit 1
	fi

	tmp_sql="$(mktemp)"
	cat > "$tmp_sql" <<-EOSQL
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${mysql_root_password_sql}';
		DELETE FROM mysql.user WHERE User='';
		DROP DATABASE IF EXISTS test;
		DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
	EOSQL

	if [ -n "$mysql_database" ]; then
		cat >> "$tmp_sql" <<-EOSQL
			CREATE DATABASE IF NOT EXISTS \`${mysql_database_sql}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
		EOSQL
	fi

	if [ -n "$mysql_user" ]; then
		cat >> "$tmp_sql" <<-EOSQL
			CREATE USER IF NOT EXISTS '${mysql_user_sql}'@'%' IDENTIFIED BY '${mysql_password_sql}';
		EOSQL
		if [ -n "$mysql_database" ]; then
			cat >> "$tmp_sql" <<-EOSQL
				GRANT ALL PRIVILEGES ON \`${mysql_database_sql}\`.* TO '${mysql_user_sql}'@'%';
			EOSQL
		else
			cat >> "$tmp_sql" <<-EOSQL
				GRANT ALL PRIVILEGES ON *.* TO '${mysql_user_sql}'@'%' WITH GRANT OPTION;
			EOSQL
		fi
	fi

	cat >> "$tmp_sql" <<-EOSQL
		FLUSH PRIVILEGES;
	EOSQL

	mariadb --socket="$SOCKET" -uroot < "$tmp_sql"
	rm -f "$tmp_sql"

	mariadb-admin --socket="$SOCKET" -uroot -p"$mysql_root_password" shutdown
	wait "$pid"
	echo "MariaDB initialization complete"
else
	echo "MariaDB data directory already initialized; skipping bootstrap"
fi

exec "$@"
