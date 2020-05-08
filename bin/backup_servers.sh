#!/bin/bash

# General variables
BACKUP_USER="barrelmaker"
BACKUP_HOST="pollux"

# Minecraft variables
MINECRAFT_FILENAME="mc-servers-$(date +%m-%d-%Y).zip"
MINECRAFT_BACKUP_DESTINATION="/mnt/Backup/mc-servers"
MINECRAFT_BACKUP_SOURCE="/home/barrelmaker/mc-servers"

# Factorio variables
FACTORIO_FILENAME="factorio-servers-$(date +%m-%d-%Y).zip"
FACTORIO_BACKUP_DESTINATION="/mnt/Backup/factorio-servers"
FACTORIO_BACKUP_SOURCE="/home/barrelmaker/factorio-servers"

minecraft_backup ()
{
	cd "${MINECRAFT_BACKUP_SOURCE}" || exit
	zip -r /tmp/"${MINECRAFT_FILENAME}" ./*
	rsync -a /tmp/"${MINECRAFT_FILENAME}" "${BACKUP_USER}@${BACKUP_HOST}":"${MINECRAFT_BACKUP_DESTINATION}"
	rm -rf /tmp/"${MINECRAFT_FILENAME}"
}

factorio_backup ()
{
	cd "${FACTORIO_BACKUP_SOURCE}" || exit
	zip -r /tmp/"${FACTORIO_FILENAME}" ./*
	rsync -a /tmp/"${FACTORIO_FILENAME}" "${BACKUP_USER}@${BACKUP_HOST}":"${FACTORIO_BACKUP_DESTINATION}"
	rm -rf /tmp/"${FACTORIO_FILENAME}"
}

if ssh -q ${BACKUP_HOST} [[ -f "${MINECRAFT_BACKUP_DESTINATION}/${MINECRAFT_FILENAME}" ]]
then
	echo "Minecraft Servers backup for today already complete"
else
	minecraft_backup
fi

if ssh -q ${BACKUP_HOST} [[ -f "${FACTORIO_BACKUP_DESTINATION}/${FACTORIO_FILENAME}" ]]
then
	echo "Factorio Servers backup for today already complete"
else
	factorio_backup
fi
