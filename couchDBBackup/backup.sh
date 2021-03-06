#!/bin/bash
#
# Export a list of CouchDB databases from the server to JSON files.
# Then bundle the exported files into a tar archive.
# usage:
# ./backup.sh mode=[test|production]


#first , check the argument of command
echo $1
isTest="true"
if [ $1 == "mode=test" ];then
	echo "TEST"
	isTest="true"
elif [ $1 == "mode=production" ];then
	echo "PRODUCTION"
	isTest="false"
else
	echo "do not set the mode,usage: mode=test | mode=production "
	exit 1;
fi

echo "begin..."
echo "isTest:$isTest"
 
TIMESTAMP=$(date "+%Y%m%d-%H%M%S")
# Adjust the location as appropriate.
SERVER="192.168.31.180"
PORT="5984"
if [ $isTest == "true" ];then
	BACKUP_DIR="/data/backup/test"
	DATABASES=("test_logger_oliver" "test_logger_deanchen");
else
	BACKUP_DIR="/data/backup/production"
	DATABASES=("logger_oliver" "logger_deanchen");
fi
mkdir -p $BACKUP_DIR
TAR_FILE="${BACKUP_DIR}/couch-backup-${TIMESTAMP}.tar.gz"

 
FILES=""
for DATABASE in ${DATABASES[@]}; do
	echo "deal with ${DATABASE}"
	FILE="/tmp/${DATABASE}.json"

	curl -X GET \
		http://${SERVER}:${PORT}/${DATABASE}/_all_docs?include_docs=true \
		> ${FILE}
	# Build a list of the files to add to the archive.
	FILES="${FILES} ${FILE}"
	echo "FILES : ${FILES}"
done
 
# Tar and gzip the exported files.
echo "backup data to file:${TAR_FILE};"
tar -zcf ${TAR_FILE} ${FILES}
