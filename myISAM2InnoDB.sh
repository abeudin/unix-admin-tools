#!/bin/sh

# Script converts all tables of all mysql-databases (except "mysql" and "information_schema", these are systemtables) from * to InnoDB
#
# Ĺicence: GPL2
# Authors: fabian (2008)
# Changelog:
#
#	v1.0.1	don't convert system tables for that may result into a broken mysql-installation
# 	v1.0 	initial release
#

MYSQL_ROOT_PW=$1

for db in `mysql -u root --password=$MYSQL_ROOT_PW --batch --column-names=false -e "show databases" | grep -v "^mysql$" | grep -v "^information_schema$"`;
do
	echo "= converting $db"
	for table in `mysql -u root --password=$MYSQL_ROOT_PW --batch --column-names=false -e "show tables" $db`;
	do
		echo "== converting $db.$table"
		mysql -u root --password=$MYSQL_ROOT_PW -e "alter table $table type=InnoDB" $db;
	done
done
