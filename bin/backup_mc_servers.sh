#!/bin/bash
BACKUP_HOST="pi@pollux"
FILENAME="mc-servers-$(date +%m-%d-%Y).zip"
BACKUP_LOCATION="/mnt/Backup"

backup ()
{
	zip -r /tmp/"${FILENAME}" /home/barrelmaker/*craft
	rsync -a /tmp/"${FILENAME}" "${BACKUP_HOST}":"${BACKUP_LOCATION}"
	rm -rf /tmp/"${FILENAME}"
}

if ssh -q ${BACKUP_HOST} [[ -f "${BACKUP_LOCATION}/${FILENAME}" ]]
then
	echo "Backup for today already complete"
else
	backup
fi
