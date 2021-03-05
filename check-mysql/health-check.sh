#!/bin/sh
while ! mysqladmin ping -h"$DB_HOST" --silent; do
    sleep 1
done

mysql -h"$DB_HOST" -uroot -p"$MYSQL_ROOT_PASSWORD" -e "create database IF NOT EXISTS milvus"; 