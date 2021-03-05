#!/bin/sh
echo "Started creating directory"

#hardcoding the password for mysql here we can get it from secretmanager or other secured medium
mysqlpassword='vignesmysql'

if [ ! -d "data" ]
then
	mkdir -p {data,./data/milvus,./data/milvus/db,./data/milvus/conf,./data/milvus/logs,./data/milvus/wal,./data/mysql,./data/mysql/conf,./data/mysql/db,./data/prometheus,./data/grafana}
	cd ./config/milvus/;
	yq eval '.general.meta_uri="mysql://root:$mysqlpassword@mysql:3306/milvus"' server_config.yaml > ./server_config_new.yaml
	echo "MYSQL_ROOT_PASSWORD=$mysqlpassword" >  ../mysql/mysql.env;
	echo "MYSQL_ROOT_PASSWORD=$mysqlpassword" >> ../../check-mysql/check.env;
	echo "SQLALCHEMY_DATABASE_URI: mysql+pymysql://root:"$mysqlpassword"@milvus:3306/milvus?charset=utf8mb4" >> ../mishards/mishards.env;
	echo "REMOVING THE file";
	mysqlpassword=$mysqlpassword envsubst < server_config_new.yaml > ./server_config_rw.yaml;
	yq eval '.cluster.role="ro"' server_config_rw.yaml > ./server_config_ro.yaml;
    rm -rf ./server_config_new.yaml;
	cd -;
fi


echo "Started building the docker image"

#For production enviromenents we need mysql as metadata service
docker-compose build --no-cache && docker-compose up 
