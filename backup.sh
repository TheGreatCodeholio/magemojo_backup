#!/bin/bash

################################################################
##
##   Magento Backup Script
##   Written By: Ian Carey
##   Last Update: Feb 06, 2020
##
################################################################

export PATH=/bin:/usr/bin:/usr/local/bin
TODAY=`date +"%d%b%Y"`

################################################################
################## Update below values  ########################
ROOT_PATH='/srv/public_html'
BACKUP_PATH='/srv/backups'
MYSQL_HOST='mysql'
MYSQL_PORT='3306'
MYSQL_USER='user_uuid'
MYSQL_PASSWORD='password'
DATABASE_NAME='db_uuid'
BACKUP_RETAIN_DAYS=30   ## Number of days to keep local backup copy

#################################################################

mkdir -p ${BACKUP_PATH}/${TODAY}
echo -e "\e[33mDatabase Backup started for - ${DATABASE_NAME}\e[0m"

mysqldump --skip-lock-tables --single-transaction -h ${MYSQL_HOST} \
   -P ${MYSQL_PORT} \
   -u root \
   -p${MYSQL_PASSWORD} \
   ${DATABASE_NAME} > ${BACKUP_PATH}/${TODAY}/db_${TODAY}.sql

if [ $? -eq 0 ]; then
  echo -e "\e[92mDatabase backup successfully completed\e[0m"
else
  echo -e "\e[31mError found during backup\e[0m"
  exit 1
fi

cd ${BACKUP_PATH}/${TODAY}

echo -e "\e[33mSite Backup started for - ${ROOT_PATH}\e[0m"
echo -e "\e[92mNot including logs, as they can change while compressing.\e[0m"
tar --exclude="${ROOT_PATH}/var/log" -czf html_${TODAY}.tar.gz ${ROOT_PATH}

if [ $? -eq 0 ]; then
  echo -e "\e[92mSite backup successfully completed\e[0m"
else
  echo -e "\e[31mError found during backup\e[0m"
  exit 1
fi

##### Remove backups older than {BACKUP_RETAIN_DAYS} days  #####

DBDELDATE=`date +"%d%b%Y" --date="${BACKUP_RETAIN_DAYS} days ago"`

if [ ! -z ${BACKUP_PATH} ]; then
      cd ${BACKUP_PATH}
      if [ ! -z ${DBDELDATE} ] && [ -d ${DBDELDATE} ]; then
            rm -rf ${DBDELDATE}
      fi
fi

### End of script ####
