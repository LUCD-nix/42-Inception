FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        mariadb-server \
        mariadb-client \
    && rm -rf /var/lib/apt/lists/*

COPY conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh \
    && rm -rf /var/lib/mysql/* \
    && mkdir -p /var/lib/mysql /run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql /run/mysqld

VOLUME ["/var/lib/mysql"]
EXPOSE 3306

ENTRYPOINT ["entrypoint.sh"]
CMD ["mariadbd", "--user=mysql", "--console"]
