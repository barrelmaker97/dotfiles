#!/bin/bash
BACKUP_HOST="pi@pollux"
FILENAME="mc-servers-$(date +%m-%d-%Y).zip"
BACKUP_LOCATION="/mnt/Backup"

backup ()
{
	zip -r /tmp/"${FILENAME}" /home/barrelmaker/*craft
	rsync -a /tmp/"${FILENAME}" "${BACKUP_HOST}":/mnt/Backup/
	rm -rf /tmp/"${FILENAME}"
}

ssh -q ${BACKUP_HOST} [[ -f "${BACKUP_LOCATION}/${FILENAME}" ]] && echo "Backup for today already complete" || backup
