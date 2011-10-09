#!/bin/bash

# DBMS
function list_mysql {
	echo "show databases;" | mysql --column-names=false | grep -v information_schema
}

function dump_mysql {
	db_name=$1
	dump_file=$2
	mysqldump --comments=0 --extended-insert=false $db_name > "$dump_file"
}

function list_postgres {
	echo "SELECT datname FROM pg_database;" | psql -t postgres -A | grep -v "^template.$"
}

function dump_postgres {
	db_name=$1
	dump_file=$2
	pg_dump $db_name > $dump_file
}
# End DBMS

# ensure good permissions:
umask 0077

if [[ $(id -u) -ne "0" ]]; then
	echo "Must be root to create backups."
	exit 1
fi

# DefaultConfiguration
databases="mysql"
backup_basedir="/var/backups/dbdumps.git/"
backup_user="root"
backup_permissions="600"

# load Configuration
if [[ -e "/etc/gitdbdump.conf" ]]; then
    source /etc/gitdbdump.conf
else
    echo "Warning: /etc/dbbackup.conf not found" 
fi

# create and enter BaseDir
if [[ ! -d "$backup_basedir" ]]; then
	echo "$0: Warning: $backup_basedir doesn't exist."
	mkdir -p $backup_basedir
fi
cd $backup_basedir

# git init
git init

# empty repo
rm -Rf $backup_basedir/*

# dump
for db in $databases; do
	echo "= dumping $db databases"
	dump_dir="$backup_basedir/$db/"
	if [[ ! -d "$dump_dir" ]]; then
		mkdir -p $dump_dir
	fi
	for db_name in `list_$db`; do
		echo "-- dumping $db_name"
		dump_file="$dump_dir/$db_name.sql"
		dump_$db $db_name $dump_file
		
	done
done

# commit to repository
echo "= adding to repository"
git add *
COMMIT_MSG="`date`"
git commit -a -m "$COMMIT_MSG"
git gc

# Fix perms
chown -R $backup_user $backup_basedir
chmod -R $backup_permissions $backup_basedir
