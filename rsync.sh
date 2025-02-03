#!/bin/bash
set -euo pipefail

################################################################
##  Restore Script using rsync
##  This script will pull files from a remote server and
##  overwrite local files in the specified directory.
################################################################

#-----------------#
# CONFIGURE HERE  #
#-----------------#
REMOTE_HOST="ssh-virginia-211-12.mojostratus.io"
REMOTE_PORT="22197"
REMOTE_USER="transfer"
REMOTE_PATH="/srv/public_html"   # Remote directory to sync from
LOCAL_PATH="/srv/public_html"    # Local directory to sync to
SSH_KEY="$HOME/.ssh/id_rsa"      # Path to your SSH private key

#-----------------#
#    EXECUTION    #
#-----------------#

echo -e "\e[33m[INFO] Starting restore from ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}\e[0m"
echo -e "\e[33m[INFO] Using SSH key at ${SSH_KEY} on port ${REMOTE_PORT}\e[0m"

rsync -Pav \
  -e "ssh -p ${REMOTE_PORT} -i ${SSH_KEY}" \
  "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/" \
  "${LOCAL_PATH}/"

echo -e "\e[92m[INFO] Restore completed successfully!\e[0m"

exit 0
