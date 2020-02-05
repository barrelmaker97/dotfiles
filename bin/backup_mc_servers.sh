#!/bin/bash
FILENAME="mc-servers-$(date +%m-%d-%Y).zip"
zip -r /tmp/"${FILENAME}" /home/barrelmaker/*craft
rsync -a /tmp/"${FILENAME}" pi@pollux:/mnt/Backup/
rm -rf /tmp/"${FILENAME}"
