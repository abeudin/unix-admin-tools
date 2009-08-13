#!/bin/bash

# Script dumps all databases of given database-systems. Daily, weekly and monthly can be configured independently.
# Pluggable architecture: for new database-systems, just add two functions:
# 	list_<dbsystem>								lists all databases in a system
#	dump_<dbsystem> $dbname $dumpfile			dumps selected database ($dbname) in $dumpfile
#
# Ĺicence: GPL2
# Authors: fabian (2008)
# Changelog:
#
#   v1.0	initial release
#   v1.1	fixed an issue which prevented old files from being deleted
#

# ensure good permissions:
umask 0077

if [[ $(id -u) -ne "0" ]]; then
	echo "Must be root to create backups."
	exit 1
fi

# Commandline
force_backup="false"
if [[ $1 = "-f" || $1 = "--force" ]]; then
	force_backup="true"
fi

# Konfiguration
backup_basedir="/var/backups/dbdumps"
databases=""
mysql_user="root"
mysql_pass=""

## Backupzeiten
monthly_backups=12 # keep 12 monthly backups (1 year)
weekly_backups=12 # keep 12 weekly backups (3 months)
daily_backups=31 # daily 31 backups (1 month)

# Konfiguration laden
if [[ -e "/etc/dbbackup.conf" ]]; then
    source /etc/dbbackup.conf
else
    echo "Warning: /etc/dbbackup.conf not found" >&2 
fi

# BaseDir anlegen
if [[ ! -d "$backup_basedir" ]]; then
	echo "$0: Warning: $backup_basedir doesn't exist."
	mkdir -p $backup_basedir
fi

# MySQL
function list_mysql {
	echo "show databases;" | mysql -u $mysql_user --password=$mysql_pass --column-names=false;
}

function dump_mysql {
	db_name=$1
	dump_file=$2
	mysqldump -u $mysql_user --password=$mysql_pass $db_name > "$dump_file"
}

# Postgres
function list_postgres {
	echo "SELECT datname FROM pg_database;" | psql -t postgres -A | grep -v "^template.$"
}

function dump_postgres {
	db_name=$1
	dump_file=$2
	pg_dump $db_name > $dump_file
}

# Ejabberd
function list_ejabberd {
	echo "ejabberd"
}

function dump_ejabberd {
	db_name=$1
	dump_file=$2
	temp_file=`mktemp`
	chown ejabberd $temp_file
	/usr/sbin/ejabberdctl dump $temp_file
	mv $temp_file $dump_file
}

# generische Funktion die das geeignete Dumpskript aufruft, dann gzip und md5 macht
function dump_zip_md5 {
	db_type=$1
	db_name=$2
	dump_file=$3
	echo -n "dumping $db_name to $dump_file... dump,"
	dump_$db_type $db_name $dump_file
	echo -n " gzip,"
	gzip -f -9 "$dump_file"
	echo " checksum"
	md5sum "$dump_file.gz" > "$dump_file.gz.md5"
}

if [[ $daily_backups = 0 ]]; then
	echo "Note: skipping daily backups (set to 0)"
fi
if [[ $monthly_backups = 0 ]]; then
	echo "Note: skipping monthly backups (set to 0)"
fi
if [[ $weekly_backups = 0 ]]; then
	echo "Note: skipping weekly backups (set to 0)"
fi

# Dump
for db in $databases; do
	echo "= dumping $db databases"
	for db_name in `list_$db`; do
		echo "-- dumping $db_name"

		# see if dump_dir exists and create it.
		dump_dir="$backup_basedir/$db/$db_name"
		if [[ ! -d "$dump_dir" ]]; then
			mkdir -p $dump_dir
		fi

		# Daily dump
		if [[ ! $daily_backups = 0 ]]; then
			dailydump_file="$dump_dir/$db_name-$(date +%F).sql"
			if [ ! -f "$dailydump_file.gz" -o $force_backup = "true" ]; then
				echo -n "--- daily backup for `date +%F`: "
				dump_zip_md5 $db $db_name $dailydump_file
			fi
		fi

		# Monthly dump
		if [[ ! $monthly_backups = 0 ]]; then
			monthlydump_file="$dump_dir/$db_name-monthly-$(date +%Y-%m).sql"
			if [ ! -f "$monthlydump_file.gz" -o $force_backup = "true" ]; then
				echo -n "--- monthly backup for `date +%B`: "
				dump_zip_md5 $db $db_name $monthlydump_file
			fi
		fi

		# Weekly dump
		if [[ ! $weekly_backups = 0 ]]; then
			weeklydump_file="$dump_dir/$db_name-weekly-$(date +%Y-%W).sql"
			if [ ! -f "$weeklydump_file.gz" -o $force_backup = "true" ]; then
				echo -n "--- weekly backup `date +%W`. week: "
				dump_zip_md5 $db $db_name $weeklydump_file
			fi
		fi
	
		# Delete old daily backups
		find $dump_dir -type f -mtime +$daily_backups -name "$db_name-[^mw]*" -delete
	
		# Delete monthly backups
		find $dump_dir -type f -mtime +$(expr $monthly_backups \* 31) -name "$db_name-monthly*" -delete
	
		# Delete weekly backups
		find $dump_dir -type f -mtime +$(expr $weekly_backups \* 7) -name "$db_name-weekly*" -delete
	done
done
