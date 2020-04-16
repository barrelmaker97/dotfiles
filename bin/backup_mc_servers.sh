#!/bin/bash
BACKUP_HOST="pi@pollux"
FILENAME="mc-servers-$(date +%m-%d-%Y).zip"
BACKUP_DESTINATION="/mnt/Backup/mc-servers"
BACKUP_SOURCE="/home/barrelmaker/mc-servers"

backup ()
{
	cd "${BACKUP_SOURCE}" || exit
	zip -r /tmp/"${FILENAME}" ./*
	rsync -a /tmp/"${FILENAME}" "${BACKUP_HOST}":"${BACKUP_DESTINATION}"
	rm -rf /tmp/"${FILENAME}"
}

if ssh -q ${BACKUP_HOST} [[ -f "${BACKUP_DESTINATION}/${FILENAME}" ]]
then
	echo "Backup for today already complete"
else
	backup
fi
