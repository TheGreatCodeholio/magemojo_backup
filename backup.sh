#!/bin/bash
set -euo pipefail

################################################################
##
##   Magento Backup Script
##   Written By: Ian Carey
##   Last Update: Feb 06, 2020
##
################################################################

export PATH=/bin:/usr/bin:/usr/local/bin
TODAY="$(date +"%d%b%Y")"

################################################################
################## Update below values  ########################
ROOT_PATH='/srv/public_html'
BACKUP_PATH='/srv/backups'
MYSQL_HOST='mysql'
MYSQL_PORT='3306'
MYSQL_USER='root'
MYSQL_PASSWORD='password'
DATABASE_NAME='db_uuid'
BACKUP_RETAIN_DAYS=30
#################################################################

# Create backup directory for today's date
mkdir -p "${BACKUP_PATH}/${TODAY}"

echo -e "\e[33m[INFO] Starting database backup for ${DATABASE_NAME}\e[0m"

mysqldump --single-transaction --quick --routines --triggers \
  -h "${MYSQL_HOST}" \
  -P "${MYSQL_PORT}" \
  -u "${MYSQL_USER}" \
  -p"${MYSQL_PASSWORD}" \
  "${DATABASE_NAME}" > "${BACKUP_PATH}/${TODAY}/db_${TODAY}.sql"

echo -e "\e[92m[INFO] Database backup completed successfully.\e[0m"

# Change to today's backup directory
cd "${BACKUP_PATH}/${TODAY}"

echo -e "\e[33m[INFO] Starting site backup for ${ROOT_PATH}, excluding 'var' folder.\e[0m"

# Create a tar.gz of the site, excluding the entire var directory
tar --exclude="${ROOT_PATH}/var" -czf "html_${TODAY}.tar.gz" "${ROOT_PATH}"

echo -e "\e[92m[INFO] Site backup completed successfully.\e[0m"

################################################################
# Remove backups older than BACKUP_RETAIN_DAYS
################################################################
echo -e "\e[33m[INFO] Removing backups older than ${BACKUP_RETAIN_DAYS} days.\e[0m"
OLD_DATE="$(date +"%d%b%Y" --date="${BACKUP_RETAIN_DAYS} days ago")"

# Only proceed if the directory exists
if [ -d "${BACKUP_PATH}/${OLD_DATE}" ]; then
  rm -rf "${BACKUP_PATH:?}/${OLD_DATE}"
  echo -e "\e[92m[INFO] Removed ${BACKUP_PATH}/${OLD_DATE}.\e[0m"
else
  echo -e "\e[33m[INFO] No backups found for ${OLD_DATE}.\e[0m"
fi

echo -e "\e[92m[INFO] Backup script completed successfully!\e[0m"
exit 0
